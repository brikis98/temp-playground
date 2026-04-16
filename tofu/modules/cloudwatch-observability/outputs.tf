output "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

output "dashboard_url" {
  description = "AWS Console URL for the CloudWatch dashboard."
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.this.dashboard_name}"
}

output "application_log_group_name" {
  description = "Application log group used by Logs Insights query definitions."
  value       = local.app_log_group_name
}

output "recent_requests_query_id" {
  description = "CloudWatch query definition ID for recent requests."
  value       = aws_cloudwatch_query_definition.recent_requests.query_definition_id
}

output "latency_by_route_query_id" {
  description = "CloudWatch query definition ID for latency by route."
  value       = aws_cloudwatch_query_definition.latency_by_route.query_definition_id
}

output "errors_query_id" {
  description = "CloudWatch query definition ID for request errors."
  value       = aws_cloudwatch_query_definition.errors.query_definition_id
}
