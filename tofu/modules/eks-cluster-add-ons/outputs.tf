output "external_dns_iam_role_arn" {
  description = "IAM role ARN used by ExternalDNS service account."
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].arn : null
}

output "argocd_namespace" {
  description = "Kubernetes namespace for the EKS managed Argo CD capability."
  value       = var.enable_argocd ? var.argocd_namespace : null
}

output "argocd_capability_arn" {
  description = "ARN of the EKS managed Argo CD capability."
  value       = var.enable_argocd ? aws_eks_capability.argocd[0].arn : null
}
