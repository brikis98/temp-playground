# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "cloud_access_policy_token" {
  description = "Grafana Cloud access policy token with permissions to activate products and manage synthetic monitoring."
  type        = string
  sensitive   = true
}

variable "grafana_cloud_stack_id" {
  description = "Grafana Cloud stack ID for synthetic monitoring installation."
  type        = number
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_kubernetes_monitoring" {
  description = "Set to true to activate Grafana Cloud Kubernetes Monitoring."
  type        = bool
  default     = true
}

variable "enable_application_observability" {
  description = "Set to true to activate Grafana Cloud Application Observability."
  type        = bool
  default     = true
}

variable "enable_synthetic_monitoring" {
  description = "Set to true to install Synthetic Monitoring for the stack."
  type        = bool
  default     = false
}

variable "synthetic_monitoring_metrics_publisher_key" {
  description = "Synthetic Monitoring metrics publisher key from Grafana Cloud."
  type        = string
  sensitive   = true
  default     = null
}

variable "synthetic_monitoring_default_probe_count" {
  description = "Number of public probes to auto-select when probe IDs are not specified."
  type        = number
  default     = 3
}

variable "synthetic_monitoring_public_probe_ids" {
  description = "Optional explicit list of probe IDs for synthetic checks."
  type        = list(number)
  default     = []
}

variable "frontend_synthetic_url" {
  description = "Frontend URL for the synthetic HTTP check."
  type        = string
  default     = ""
}

variable "backend_synthetic_url" {
  description = "Backend URL for the synthetic HTTP check."
  type        = string
  default     = ""
}
