locals {
  app_log_group_name = var.application_log_group_name != "" ? var.application_log_group_name : "/aws/containerinsights/${var.cluster_name}/application"

  dashboard_widgets = concat(
    [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Frontend Requests/Min"
          view   = "timeSeries"
          region = var.region
          stat   = "SampleCount"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.frontend_service_name]
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
          title  = "Frontend Latency p50 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p50"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.frontend_service_name]
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
          title  = "Frontend Latency p95 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p95"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.frontend_service_name]
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
          title  = "Frontend Latency p99 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p99"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.frontend_service_name]
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
          title  = "Frontend 4xx Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["ApplicationSignals", "Error", "Environment", var.application_signals_environment, "Service", var.frontend_service_name]
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
          title  = "Frontend 5xx Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["ApplicationSignals", "Fault", "Environment", var.application_signals_environment, "Service", var.frontend_service_name]
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
          title  = "Backend Requests/Min"
          view   = "timeSeries"
          region = var.region
          stat   = "SampleCount"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.backend_service_name]
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
          title  = "Backend Latency p50 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p50"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.backend_service_name]
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
          title  = "Backend Latency p95 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p95"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.backend_service_name]
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
          title  = "Backend Latency p99 (ms)"
          view   = "timeSeries"
          region = var.region
          stat   = "p99"
          period = 60
          metrics = [
            ["ApplicationSignals", "Latency", "Environment", var.application_signals_environment, "Service", var.backend_service_name]
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
          title  = "Backend 4xx Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["ApplicationSignals", "Error", "Environment", var.application_signals_environment, "Service", var.backend_service_name]
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
          title  = "Backend 5xx Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["ApplicationSignals", "Fault", "Environment", var.application_signals_environment, "Service", var.backend_service_name]
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
          title  = "Frontend Logs"
          query  = format("SOURCE '%s' | fields @timestamp, @logStream, @message | filter @logStream like /%s/ or @message like /%s/ | sort @timestamp desc | limit 200", local.app_log_group_name, var.frontend_service_name, var.frontend_service_name)
          region = var.region
          view   = "table"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 32
        width  = 24
        height = 8
        properties = {
          title  = "Backend Logs"
          query  = format("SOURCE '%s' | fields @timestamp, @logStream, @message | filter @logStream like /%s/ or @message like /%s/ | sort @timestamp desc | limit 200", local.app_log_group_name, var.backend_service_name, var.backend_service_name)
          region = var.region
          view   = "table"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 40
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
        y      = 40
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
        y      = 40
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
        y      = 46
        width  = 8
        height = 6
        properties = {
          title  = "Node Disk Utilization (%)"
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["ContainerInsights", "node_filesystem_utilization", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 46
        width  = 8
        height = 6
        properties = {
          title  = "Pod Restart Count"
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["ContainerInsights", "pod_number_of_container_restarts", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 52
        width  = 24
        height = 8
        properties = {
          title  = "Latency by Route"
          query  = format("SOURCE '%s' | fields @message | filter @message like /\\\"event\\\":\\\"http_request\\\"/ | filter @message like /\\\"service\\\":\\\"%s\\\"/ or @message like /\\\"service\\\":\\\"%s\\\"/ | parse @message /\\\"route\\\":\\\"(?<route>[^\\\"]+)\\\"/ | parse @message /\\\"path\\\":\\\"(?<path>[^\\\"]+)\\\"/ | parse @message /\\\"duration_ms\\\":(?<duration_ms>[0-9.]+)/ | stats pct(duration_ms, 50) as p50_ms, pct(duration_ms, 90) as p90_ms, pct(duration_ms, 95) as p95_ms, pct(duration_ms, 99) as p99_ms, count(*) as requests by coalesce(route, path) as request_path | sort p95_ms desc | limit 100", local.app_log_group_name, var.frontend_service_name, var.backend_service_name)
          region = var.region
          view   = "table"
        }
      }
    ]
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name_prefix}-${var.cluster_name}"
  dashboard_body = jsonencode({
    widgets = local.dashboard_widgets
  })
}
