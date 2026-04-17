# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

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

variable "grafana_cloud_stack_id" {
  description = "Grafana Cloud stack ID. Required if enable_synthetic_monitoring is true. Go to https://grafana.com/ -> Login to your account -> Click on your stack Under Grafana Cloud -> Click Details in the Grafana Cloud box -> Find the stack ID."
  type        = number
  default     = null
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
