# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "dashboard_region" {
  description = "AWS region used by CloudWatch queries."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used in CloudWatch query dimensions."
  type        = string
}

variable "app_name" {
  description = "Kubernetes app/container name used by logs queries."
  type        = string
}

variable "dashboard_title" {
  description = "Title of the app dashboard."
  type        = string
}

variable "dashboard_uid" {
  description = "Stable UID for the app dashboard."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace for app filters."
  type        = string
  default     = "default"
}

variable "set_as_home_dashboard" {
  description = "Set to true to make this dashboard the organization home dashboard."
  type        = bool
  default     = true
}
