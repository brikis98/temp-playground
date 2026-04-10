output "external_dns_enabled" {
  description = "Whether ExternalDNS installation is enabled."
  value       = var.enable_external_dns
}

output "external_dns_iam_role_arn" {
  description = "IAM role ARN used by ExternalDNS service account when enabled."
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].arn : null
}
