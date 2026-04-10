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

output "external_dns_enabled" {
  description = "Whether ExternalDNS installation is enabled."
  value       = module.eks_cluster_add_ons.external_dns_enabled
}

output "external_dns_iam_role_arn" {
  description = "IAM role ARN used by ExternalDNS service account when enabled."
  value       = module.eks_cluster_add_ons.external_dns_iam_role_arn
}
