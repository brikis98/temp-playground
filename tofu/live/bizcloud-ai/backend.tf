terraform {
  backend "s3" {
    bucket       = "devops-foundations-temp-playground-state-bucket"
    key          = "tofu/live/bizcloud-ai/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}