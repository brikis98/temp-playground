output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate authority of the EKS cluster"
  value       = module.eks_cluster.cluster_certificate_authority
}

output "external_dns_addon_arn" {
  description = "ARN of the ExternalDNS EKS add-on when enabled."
  value       = module.eks_cluster_add_ons.external_dns_addon_arn
}

output "cloudwatch_observability_addon_arn" {
  description = "ARN of the CloudWatch Observability EKS add-on when enabled."
  value       = module.eks_cluster_add_ons.cloudwatch_observability_addon_arn
}

output "bizcloud_ai_ecr_repo_url" {
  description = "URL of the bizcloud-ai ECR repo"
  value       = aws_ecr_repository.bizcloud_ai.repository_url
}

output "bizcloud_frontend_ecr_repo_url" {
  description = "URL of the bizcloud-frontend ECR repo"
  value       = aws_ecr_repository.bizcloud_frontend.repository_url
}

output "bizcloud_backend_ecr_repo_url" {
  description = "URL of the bizcloud-backend ECR repo"
  value       = aws_ecr_repository.bizcloud_backend.repository_url
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider used by CI roles"
  value       = module.github_actions_oidc_iam.github_oidc_provider_arn
}

output "github_actions_docker_push_role_arn" {
  description = "IAM role ARN for Docker build/push workflow"
  value       = module.github_actions_oidc_iam.docker_push_role_arn
}

output "github_actions_tofu_plan_role_arn" {
  description = "IAM role ARN for tofu plan workflow"
  value       = module.github_actions_oidc_iam.tofu_plan_role_arn
}

output "github_actions_tofu_apply_role_arn" {
  description = "IAM role ARN for tofu apply workflow"
  value       = module.github_actions_oidc_iam.tofu_apply_role_arn
}
