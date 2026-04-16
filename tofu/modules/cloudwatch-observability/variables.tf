# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "EKS cluster name used for Container Insights and log group naming."
  type        = string
}

variable "region" {
  description = "AWS region for CloudWatch widgets and console URL output."
  type        = string
}

variable "frontend_service_name" {
  description = "Frontend service name used in Application Signals and Logs Insights filtering."
  type        = string
}

variable "backend_service_name" {
  description = "Backend service name used in Application Signals and Logs Insights filtering."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix used for CloudWatch dashboard and query names."
  type        = string
  default     = "bizcloud-observability"
}

variable "namespace" {
  description = "Kubernetes namespace used for certain Container Insights widget filters."
  type        = string
  default     = "default"
}

variable "application_log_group_name" {
  description = "CloudWatch Logs group for application logs. If empty, defaults to Container Insights application log group for the cluster."
  type        = string
  default     = ""
}