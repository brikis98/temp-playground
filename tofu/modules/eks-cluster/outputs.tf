output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate authority of the EKS cluster"
  value       = aws_eks_cluster.cluster.certificate_authority
}

output "cluster_identity_oidc_issuer" {
  description = "OIDC issuer URL for the EKS cluster."
  value       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
