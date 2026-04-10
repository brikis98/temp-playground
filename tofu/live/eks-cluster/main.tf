provider "aws" {
  region = "us-east-2"
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  name                     = "jim-testing"
  eks_version              = "1.35"
  min_worker_nodes         = 2
  max_worker_nodes         = 5
  control_plane_subnet_ids = data.aws_subnets.default.ids
  worker_node_subnet_ids   = data.aws_subnets.default.ids
  instance_type            = "t3.micro"
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