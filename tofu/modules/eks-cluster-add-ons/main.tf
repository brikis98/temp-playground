data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_ssoadmin_instances" "current" {
  count = var.enable_argocd ? 1 : 0
}

locals {
  oidc_issuer_hostpath    = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_arn       = var.enable_external_dns ? aws_iam_openid_connect_provider.eks[0].arn : null
  external_dns_txt_owner  = var.cluster_name
  argocd_idc_instance_arn = var.enable_argocd ? tolist(data.aws_ssoadmin_instances.current[0].arns)[0] : null

  external_dns_values_base = {
    provider   = "aws"
    policy     = "sync"
    registry   = "txt"
    txtOwnerId = local.external_dns_txt_owner
    sources    = ["service", "ingress", "gateway-httproute"]
    serviceAccount = {
      create = false
      name   = var.external_dns_service_account_name
    }
  }

  external_dns_values = merge(local.external_dns_values_base, {
    domainFilters = var.external_dns_domain_filters
  })
}

data "tls_certificate" "cluster_oidc_issuer" {
  count = var.enable_external_dns ? 1 : 0
  url   = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.enable_external_dns ? 1 : 0

  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc_issuer[0].certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name   = "${var.cluster_name}-external-dns"
  policy = data.aws_iam_policy_document.external_dns[0].json
}

data "aws_iam_policy_document" "external_dns_assume_role" {
  count = var.enable_external_dns ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values = [
        "system:serviceaccount:${var.external_dns_namespace}:${var.external_dns_service_account_name}",
      ]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name               = "${var.cluster_name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns[0].arn
}

resource "kubernetes_service_account_v1" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  metadata {
    name      = var.external_dns_service_account_name
    namespace = var.external_dns_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns[0].arn
    }
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
}

resource "helm_release" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  version          = var.external_dns_chart_version
  namespace        = var.external_dns_namespace
  create_namespace = false

  values = [yamlencode(local.external_dns_values)]

  depends_on = [
    aws_iam_role_policy_attachment.external_dns,
    kubernetes_service_account_v1.external_dns,
  ]
}

data "aws_iam_policy_document" "argocd_capability_assume_role" {
  count = var.enable_argocd ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["capabilities.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "argocd_capability" {
  count = var.enable_argocd ? 1 : 0

  name               = "${var.cluster_name}-argocd-capability"
  assume_role_policy = data.aws_iam_policy_document.argocd_capability_assume_role[0].json
}

# Sometimes, when creating the ArgoCD capability, you get the error "The policy must include sts:AssumeRole and
# sts:TagSession actions granting access to the AWS service capabilities.eks.amazonaws.com." The IAM role defines both
# of these actions, so this is probably some sort of timing issue with the IAM role not having had time to propagate
# before the capability tries to use it. To work around that, we add a 20 second sleep.
resource "time_sleep" "argocd_role_propagated" {
  count = var.enable_argocd ? 1 : 0

  create_duration = "20s"
  depends_on      = [aws_iam_role.argocd_capability]
}

resource "aws_eks_capability" "argocd" {
  count = var.enable_argocd ? 1 : 0

  cluster_name              = var.cluster_name
  capability_name           = var.argocd_capability_name
  type                      = "ARGOCD"
  role_arn                  = aws_iam_role.argocd_capability[0].arn
  delete_propagation_policy = "RETAIN"

  configuration {
    argo_cd {
      namespace = var.argocd_namespace
      aws_idc {
        idc_instance_arn = local.argocd_idc_instance_arn
      }

      dynamic "rbac_role_mapping" {
        for_each = var.argocd_rbac_role_mapping
        content {
          role = rbac_role_mapping.value.role
          identity {
            id   = rbac_role_mapping.value.identity.id
            type = rbac_role_mapping.value.identity.type
          }
        }
      }
    }
  }

  depends_on = [time_sleep.argocd_role_propagated]
}
