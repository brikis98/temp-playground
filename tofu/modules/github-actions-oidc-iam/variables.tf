# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "github_owner" {
  description = "GitHub owner/org for the repository that can assume these roles."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name that can assume these roles."
  type        = string
}

variable "ecr_repository_arns" {
  description = "ARNs of the ECR repositories to allow Docker image pushes to."
  type        = list(string)
}

variable "tofu_state_bucket_name" {
  description = "Name of the S3 bucket that stores OpenTofu remote state."
  type        = string
}

variable "tofu_state_key" {
  description = "S3 object key for the OpenTofu remote state file."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "docker_push_role_name" {
  description = "Name of the IAM role used by docker-test-and-release workflow to push images."
  type        = string
  default     = "github-actions-docker-push"
}

variable "tofu_plan_role_name" {
  description = "Name of the IAM role used by tofu-live-plan-apply workflow for plan."
  type        = string
  default     = "github-actions-tofu-plan"
}

variable "tofu_apply_role_name" {
  description = "Name of the IAM role used by tofu-live-plan-apply workflow for apply."
  type        = string
  default     = "github-actions-tofu-apply"
}

variable "github_oidc_provider_url" {
  description = "GitHub OIDC provider URL."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints for the GitHub OIDC provider."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "create_github_oidc_provider" {
  description = "Set to true to create the GitHub OIDC provider in IAM."
  type        = bool
  default     = true
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN to use when create_github_oidc_provider is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_github_oidc_provider || var.existing_github_oidc_provider_arn != null
    error_message = "existing_github_oidc_provider_arn must be set when create_github_oidc_provider is false."
  }
}
