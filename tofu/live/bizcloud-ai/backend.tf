locals {
  tofu_state_bucket = "devops-foundations-temp-playground-state-bucket"
  tofu_state_key    = "tofu/live/bizcloud-ai/terraform.tfstate"
}

terraform {
  backend "s3" {
    bucket       = local.tofu_state_bucket
    key          = local.tofu_state_key
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}