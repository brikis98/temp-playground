output "workspace_id" {
  description = "ID of the Amazon Managed Grafana workspace."
  value       = aws_grafana_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Amazon Managed Grafana workspace."
  value       = aws_grafana_workspace.this.name
}

output "workspace_arn" {
  description = "ARN of the Amazon Managed Grafana workspace."
  value       = aws_grafana_workspace.this.arn
}

output "workspace_endpoint" {
  description = "Endpoint URL of the Amazon Managed Grafana workspace."
  value       = aws_grafana_workspace.this.endpoint
}

output "workspace_role_arn" {
  description = "IAM role ARN used by the Amazon Managed Grafana workspace."
  value       = aws_iam_role.workspace.arn
}
