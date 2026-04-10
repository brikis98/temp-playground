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

output "ecr_repo_url" {
  description = "URL of the ECR repo"
  value       = aws_ecr_repository.sample_app.repository_url
}
