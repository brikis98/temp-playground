output "dashboard_uid" {
  description = "UID of the provisioned Grafana dashboard."
  value       = grafana_dashboard.app_overview.uid
}
