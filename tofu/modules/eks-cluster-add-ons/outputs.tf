output "external_dns_iam_role_arn" {
  description = "IAM role ARN used by ExternalDNS service account."
  value       = aws_iam_role.external_dns.arn
}
