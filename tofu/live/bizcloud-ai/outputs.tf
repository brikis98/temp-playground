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

output "grafana_workspace_id" {
  description = "ID of the Amazon Managed Grafana workspace."
  value       = module.managed_grafana.workspace_id
}

output "grafana_workspace_arn" {
  description = "ARN of the Amazon Managed Grafana workspace."
  value       = module.managed_grafana.workspace_arn
}

output "grafana_workspace_endpoint" {
  description = "Endpoint URL of the Amazon Managed Grafana workspace."
  value       = module.managed_grafana.workspace_endpoint
}

output "grafana_workspace_role_arn" {
  description = "IAM role ARN used by the Amazon Managed Grafana workspace."
  value       = module.managed_grafana.workspace_role_arn
}

output "grafana_default_dashboard_uid" {
  description = "UID of the default provisioned app dashboard."
  value       = module.grafana_dashboard.dashboard_uid
}

output "ecr_repo_url" {
  description = "URL of the ECR repo"
  value       = aws_ecr_repository.sample_app.repository_url
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
