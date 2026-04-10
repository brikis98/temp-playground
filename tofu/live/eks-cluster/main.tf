provider "aws" {
  region = "us-east-2"
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  name                     = "jim-testing"
  eks_version              = "1.35"
  control_plane_subnet_ids = data.aws_subnets.default.ids
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks_cluster.cluster_name
  depends_on = [module.eks_cluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks_cluster.cluster_name
  depends_on = [module.eks_cluster]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "eks_cluster_add_ons" {
  source = "../../modules/eks-cluster-add-ons"

  cluster_name = module.eks_cluster.cluster_name

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
