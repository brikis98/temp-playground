# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster to which add-ons should be installed."
  type        = string
}

variable "external_dns_chart_version" {
  description = "The version of the ExternalDNS Helm chart to use to install ExternalDNS. See https://artifacthub.io/packages/helm/external-dns/external-dns for available versions."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "external_dns_domain_filters" {
  description = "Optional DNS suffixes ExternalDNS is allowed to manage. Empty list means no domain filter."
  type        = list(string)
  default     = []
}

variable "external_dns_namespace" {
  description = "The namespace to deploy ExternalDNS into."
  type        = string
  default     = "kube-system"
}

variable "external_dns_service_account_name" {
  description = "The name of the service account to use for ExternalDNS"
  type        = string
  default     = "external-dns"
}

variable "argocd_namespace" {
  description = "The namespace to deploy ArgoCD into."
  type        = string
  default     = "argocd"
}