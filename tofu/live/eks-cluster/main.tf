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

  enable_external_dns        = true
  external_dns_chart_version = "1.20.0"

  depends_on = [module.eks_cluster]
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
