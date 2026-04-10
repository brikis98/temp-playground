# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

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
