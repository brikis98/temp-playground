output "external_dns_addon_arn" {
  description = "ARN of the ExternalDNS EKS add-on when enabled."
  value       = var.enable_external_dns ? aws_eks_addon.external_dns[0].arn : null
}

output "cloudwatch_observability_addon_arn" {
  description = "ARN of the CloudWatch Observability EKS add-on when enabled."
  value       = var.enable_cloudwatch_observability ? aws_eks_addon.cloudwatch_observability[0].arn : null
}

output "argocd_namespace" {
  description = "Kubernetes namespace for the EKS managed Argo CD capability."
  value       = var.enable_argocd ? var.argocd_namespace : null
}

output "argocd_capability_arn" {
  description = "ARN of the EKS managed Argo CD capability."
  value       = var.enable_argocd ? aws_eks_capability.argocd[0].arn : null
}
