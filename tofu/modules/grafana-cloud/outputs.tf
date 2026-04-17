output "kubernetes_monitoring_activation_id" {
  description = "Resource ID for Kubernetes Monitoring activation."
  value       = var.enable_kubernetes_monitoring ? grafana_apps_productactivation_k8so11yconfig_v1alpha1.k8s_o11y[0].id : null
}

output "application_observability_activation_id" {
  description = "Resource ID for Application Observability activation."
  value       = var.enable_application_observability ? grafana_apps_productactivation_appo11yconfig_v1alpha1.app_o11y[0].id : null
}

output "synthetic_monitoring_installation_id" {
  description = "Synthetic Monitoring installation resource ID."
  value       = var.enable_synthetic_monitoring ? grafana_synthetic_monitoring_installation.this[0].id : null
}

output "synthetic_monitoring_frontend_check_id" {
  description = "Frontend synthetic check ID."
  value       = length(grafana_synthetic_monitoring_check.frontend_http) > 0 ? grafana_synthetic_monitoring_check.frontend_http[0].id : null
}

output "synthetic_monitoring_backend_check_id" {
  description = "Backend synthetic check ID."
  value       = length(grafana_synthetic_monitoring_check.backend_http) > 0 ? grafana_synthetic_monitoring_check.backend_http[0].id : null
}
