# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster to which add-ons should be installed."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_external_dns" {
  description = "Set to true to install ExternalDNS as an EKS add-on."
  type        = bool
  default     = false
}

variable "enable_cloudwatch_observability" {
  description = "Set to true to install the Amazon CloudWatch Observability EKS add-on for infrastructure and application telemetry."
  type        = bool
  default     = false
}

variable "cloudwatch_observability_addon_version" {
  description = "Specific CloudWatch Observability EKS add-on version to install. If null, installs latest compatible version."
  type        = string
  default     = null
}

variable "external_dns_addon_version" {
  description = "Specific ExternalDNS EKS add-on version to install. If null, installs latest compatible version."
  type        = string
  default     = null
}

variable "enable_argocd" {
  description = "Set to true to create the managed EKS Argo CD capability."
  type        = bool
  default     = false
}

variable "aws_identity_center_arn" {
  description = "The ARN of the AWS Identity Center instance to use to configure SSO for ArgoCD. Must be set of enable_argocd is true."
  type        = string
  default     = null
}

variable "argocd_namespace" {
  description = "The namespace to deploy ArgoCD into."
  type        = string
  default     = "argocd"
}

variable "argocd_capability_name" {
  description = "Name of the managed EKS Argo CD capability."
  type        = string
  default     = "argocd"
}

variable "enable_argocd_cluster_access_policy_association" {
  description = "Set to true to attach an EKS access policy to the Argo CD capability role for target-cluster access."
  type        = bool
  default     = true
}

variable "argocd_cluster_access_policy_arn" {
  description = "EKS cluster access policy ARN to associate to the Argo CD capability role."
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "argocd_rbac_role_mapping" {
  description = "The IAM Identity Center users or groups to grant access to ArgoCD via SSO. Role values must be one of: ADMIN, EDITOR, VIEWER. Identity type must be one of: SSO_USER or SSO_GROUP. Identity id must be the ID of the corresponding IAM Identity Center user or group."
  type = list(object({
    role = string
    identity = object({
      type = string
      id   = string
    })
  }))
  default = []
}
