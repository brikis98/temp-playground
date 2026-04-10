# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The base name for the EKS cluster and all other resources"
  type        = string
}

variable "eks_version" {
  description = "The version of EKS to deploy. See https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html for available versions."
  type        = string
}

variable "control_plane_subnet_ids" {
  description = "The IDs of subnets into which to deploy the EKS control plane."
  type        = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "auto_mode_node_pools" {
  description = "Built-in EKS Auto Mode node pools to enable."
  type        = list(string)
  default     = ["general-purpose", "system"]
}
