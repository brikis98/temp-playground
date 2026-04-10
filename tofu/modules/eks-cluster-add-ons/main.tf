data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

locals {
  external_dns_chart_version        = "1.18.0"

  create_oidc_provider   = var.enable_external_dns
  oidc_issuer_hostpath   = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_arn      = aws_iam_openid_connect_provider.eks[0].arn
  external_dns_txt_owner = var.cluster_name

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

  external_dns_values = length(var.external_dns_domain_filters) > 0 ? merge(local.external_dns_values_base, {
    domainFilters = var.external_dns_domain_filters
  }) : local.external_dns_values_base
}

data "tls_certificate" "cluster_oidc_issuer" {
  count = local.create_oidc_provider ? 1 : 0
  url   = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  count           = local.create_oidc_provider ? 1 : 0
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

resource "kubernetes_service_account" "external_dns" {
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
    kubernetes_service_account.external_dns,
  ]
}
