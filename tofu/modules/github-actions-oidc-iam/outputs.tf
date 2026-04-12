output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider used by these roles."
  value       = local.github_oidc_provider_arn
}

output "docker_push_role_arn" {
  description = "IAM role ARN for docker-test-and-release workflow image pushes."
  value       = aws_iam_role.docker_push.arn
}

output "tofu_plan_role_arn" {
  description = "IAM role ARN for tofu-live-plan-apply workflow plan operations."
  value       = aws_iam_role.tofu_plan.arn
}

output "tofu_apply_role_arn" {
  description = "IAM role ARN for tofu-live-plan-apply workflow apply operations."
  value       = aws_iam_role.tofu_apply.arn
}
