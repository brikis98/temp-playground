provider "aws" {
  region = "us-east-2"
}

module "s3_bucket" {
  source = "../../modules/s3-bucket"

  name = "devops-foundations-temp-playground-state-bucket"
}