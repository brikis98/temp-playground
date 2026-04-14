# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Amazon Managed Grafana workspace."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  description = "Description of the Amazon Managed Grafana workspace."
  type        = string
  default     = "Managed Grafana workspace for EKS observability."
}

variable "account_access_type" {
  description = "AWS account access type for the workspace."
  type        = string
  default     = "CURRENT_ACCOUNT"
}

variable "authentication_providers" {
  description = "Authentication providers for the workspace."
  type        = list(string)
  default     = ["AWS_SSO"]
}

variable "data_sources" {
  description = "Data sources to enable in the workspace. CLOUDWATCH covers CloudWatch Metrics and Logs Insights."
  type        = list(string)
  default     = ["CLOUDWATCH"]
}

variable "grafana_version" {
  description = "Grafana major version for the workspace. Null lets AWS pick a default."
  type        = string
  default     = null
}

variable "notification_destinations" {
  description = "Notification destinations for Grafana alerts."
  type        = list(string)
  default     = []
}

variable "admin_user_ids" {
  description = "IAM Identity Center user IDs to grant ADMIN role in Grafana."
  type        = list(string)
  default     = []
}

variable "admin_group_ids" {
  description = "IAM Identity Center group IDs to grant ADMIN role in Grafana."
  type        = list(string)
  default     = []
}

variable "editor_user_ids" {
  description = "IAM Identity Center user IDs to grant EDITOR role in Grafana."
  type        = list(string)
  default     = []
}

variable "editor_group_ids" {
  description = "IAM Identity Center group IDs to grant EDITOR role in Grafana."
  type        = list(string)
  default     = []
}

variable "viewer_user_ids" {
  description = "IAM Identity Center user IDs to grant VIEWER role in Grafana."
  type        = list(string)
  default     = []
}

variable "viewer_group_ids" {
  description = "IAM Identity Center group IDs to grant VIEWER role in Grafana."
  type        = list(string)
  default     = []
}
