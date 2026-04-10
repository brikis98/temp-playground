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
