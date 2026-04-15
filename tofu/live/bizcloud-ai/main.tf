provider "aws" {
  region = local.aws_region
}

provider "grafana" {
  url  = "https://${module.managed_grafana.workspace_endpoint}"
  auth = aws_grafana_workspace_service_account_token.dashboard_provisioner.key
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  name                     = "jim-testing"
  eks_version              = "1.35"
  control_plane_subnet_ids = data.aws_subnets.default.ids
}

module "eks_cluster_add_ons" {
  source = "../../modules/eks-cluster-add-ons"

  cluster_name = module.eks_cluster.cluster_name

  enable_cloudwatch_observability = true

  enable_external_dns = true

  enable_argocd                                   = true
  enable_argocd_cluster_access_policy_association = true
  aws_identity_center_arn                         = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  argocd_rbac_role_mapping = [
    {
      role = "ADMIN"
      identity = {
        type = "SSO_USER"
        id   = local.jim_sso_user_id
      }
    }
  ]

  depends_on = [module.eks_cluster]
}

module "managed_grafana" {
  source = "../../modules/managed-grafana"

  name           = "jim-testing-observability"
  admin_user_ids = [local.jim_sso_user_id]
}

module "grafana_dashboard" {
  source = "../../modules/grafana-dashboard"

  dashboard_uid    = "bizcloud-ai-overview"
  dashboard_title  = "BizCloud AI Overview"
  dashboard_region = local.aws_region
  cluster_name     = module.eks_cluster.cluster_name
  namespace        = "default"
  app_name         = "bizcloud-ai"

  depends_on = [module.managed_grafana]
}

resource "aws_ecr_repository" "sample_app" {
  name                 = "bizcloud-ai"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    test = "pr-test-4"
  }
}

module "github_actions_oidc_iam" {
  source = "../../modules/github-actions-oidc-iam"

  github_owner                = "brikis98"
  github_repo                 = "temp-playground"
  create_github_oidc_provider = true
  ecr_repository_arn          = aws_ecr_repository.sample_app.arn
  tofu_state_bucket_name      = local.tofu_state_bucket
  tofu_state_key              = local.tofu_state_key
}

# To use load balancing with EKS in Auto Mode, you have to add tags to subnets that the load balancers can be deployed
# into: https://docs.aws.amazon.com/eks/latest/userguide/tag-subnets-auto.html
resource "aws_ec2_tag" "subnet_tags_for_eks_load_balancers" {
  for_each    = toset(data.aws_subnets.default.ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssoadmin_instances" "current" {}

locals {
  jim_sso_user_id = "f18b8510-80d1-7024-dea5-e1a4682939be"
  aws_region      = "us-east-2"
}

resource "aws_grafana_workspace_service_account" "dashboard_provisioner" {
  workspace_id = module.managed_grafana.workspace_id
  name         = "${module.managed_grafana.workspace_name}-dashboard-provisioner"
  grafana_role = "ADMIN"
}

resource "aws_grafana_workspace_service_account_token" "dashboard_provisioner" {
  workspace_id       = module.managed_grafana.workspace_id
  service_account_id = aws_grafana_workspace_service_account.dashboard_provisioner.service_account_id
  name               = "${module.managed_grafana.workspace_name}-dashboard-provisioner-token"
  seconds_to_live    = 2592000 # 30 days
}