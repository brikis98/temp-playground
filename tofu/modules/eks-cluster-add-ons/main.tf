data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_addon_version" "external_dns" {
  count = var.enable_external_dns && var.external_dns_addon_version == null ? 1 : 0

  addon_name         = "external-dns"
  kubernetes_version = data.aws_eks_cluster.cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  cluster_name = var.cluster_name
  addon_name   = "external-dns"
  addon_version = coalesce(
    var.external_dns_addon_version,
    data.aws_eks_addon_version.external_dns[0].version,
  )

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
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

resource "aws_eks_access_policy_association" "argocd_capability_cluster_access" {
  count = var.enable_argocd && var.enable_argocd_cluster_access_policy_association ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.argocd_capability[0].arn
  policy_arn    = var.argocd_cluster_access_policy_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_iam_role.argocd_capability]
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
        idc_instance_arn = var.aws_identity_center_arn
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
