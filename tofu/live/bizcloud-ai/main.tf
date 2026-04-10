provider "aws" {
  region = "us-east-2"
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

  enable_external_dns = true

  enable_argocd            = true
  argocd_rbac_role_mapping = var.argocd_rbac_role_mapping
  aws_identity_center_arn  = tolist(data.aws_ssoadmin_instances.current.arns)[0]

  depends_on = [module.eks_cluster]
}

resource "aws_ecr_repository" "sample_app" {
  name         = "bizcloud-ai"
  force_delete = true
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