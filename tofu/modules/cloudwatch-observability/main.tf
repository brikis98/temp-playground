locals {
  app_log_group_name = var.application_log_group_name != "" ? var.application_log_group_name : "/aws/containerinsights/${var.cluster_name}/application"

  query_filter_services = "(service='${var.frontend_service_name}' or service='${var.backend_service_name}')"

  dashboard_widgets = concat(
    [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Cluster Node Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["ContainerInsights", "cluster_node_count", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Node CPU Utilization (%)"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Node Memory Utilization (%)"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Pod Network RX (bytes/s)"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["ContainerInsights", "pod_network_rx_bytes", "ClusterName", var.cluster_name, "Namespace", var.namespace]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Pod Network TX (bytes/s)"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["ContainerInsights", "pod_network_tx_bytes", "ClusterName", var.cluster_name, "Namespace", var.namespace]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Pod Restart Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["ContainerInsights", "pod_number_of_container_restarts", "ClusterName", var.cluster_name, "Namespace", var.namespace]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 8
        height = 6
        properties = {
          title  = "Frontend Request Rate"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationSignals", "RequestRate", "Service", var.frontend_service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 12
        width  = 8
        height = 6
        properties = {
          title  = "Frontend Latency p95 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p95"
          period = 60
          metrics = [
            ["AWS/ApplicationSignals", "Latency", "Service", var.frontend_service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 12
        width  = 8
        height = 6
        properties = {
          title  = "Frontend 4xx/5xx Rate"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationSignals", "ErrorRate", "Service", var.frontend_service_name, { label = "4xx" }],
            [".", "FaultRate", ".", ".", { label = "5xx" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 8
        height = 6
        properties = {
          title  = "Backend Request Rate"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationSignals", "RequestRate", "Service", var.backend_service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 18
        width  = 8
        height = 6
        properties = {
          title  = "Backend Latency p95 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p95"
          period = 60
          metrics = [
            ["AWS/ApplicationSignals", "Latency", "Service", var.backend_service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 18
        width  = 8
        height = 6
        properties = {
          title  = "Backend 4xx/5xx Rate"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationSignals", "ErrorRate", "Service", var.backend_service_name, { label = "4xx" }],
            [".", "FaultRate", ".", ".", { label = "5xx" }]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 24
        width  = 24
        height = 8
        properties = {
          title  = "Frontend + Backend HTTP Logs"
          query  = "SOURCE '${local.app_log_group_name}' | fields @timestamp, service, method, route, path, status, duration_ms, trace_id | filter event='http_request' and ${local.query_filter_services} | sort @timestamp desc | limit 200"
          region = var.region
          view   = "table"
        }
      },
    ]
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name_prefix}-${var.cluster_name}"
  dashboard_body = jsonencode({
    widgets = local.dashboard_widgets
  })
}

resource "aws_cloudwatch_query_definition" "recent_requests" {
  name = "${var.name_prefix}-${var.cluster_name}-requests-recent"

  log_group_names = [local.app_log_group_name]

  query_string = <<-EOT
    fields @timestamp, service, method, route, path, status, duration_ms, trace_id
    | filter event = "http_request"
    | filter service = "${var.frontend_service_name}" or service = "${var.backend_service_name}"
    | sort @timestamp desc
    | limit 200
  EOT
}

resource "aws_cloudwatch_query_definition" "latency_by_route" {
  name = "${var.name_prefix}-${var.cluster_name}-latency-by-route"

  log_group_names = [local.app_log_group_name]

  query_string = <<-EOT
    fields service, route, path, duration_ms
    | filter event = "http_request"
    | filter service = "${var.frontend_service_name}" or service = "${var.backend_service_name}"
    | stats pct(duration_ms, 50) as p50_ms, pct(duration_ms, 90) as p90_ms, pct(duration_ms, 95) as p95_ms, pct(duration_ms, 99) as p99_ms, count(*) as requests by service, coalesce(route, path) as request_path
    | sort p95_ms desc
  EOT
}

resource "aws_cloudwatch_query_definition" "errors" {
  name = "${var.name_prefix}-${var.cluster_name}-errors"

  log_group_names = [local.app_log_group_name]

  query_string = <<-EOT
    fields @timestamp, service, method, route, path, status, duration_ms, trace_id, @message
    | filter event = "http_request"
    | filter status >= 400
    | filter service = "${var.frontend_service_name}" or service = "${var.backend_service_name}"
    | sort @timestamp desc
    | limit 200
  EOT
}
