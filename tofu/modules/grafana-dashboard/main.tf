resource "grafana_dashboard" "app_overview" {
  config_json = jsonencode(merge(local.dashboard, {
    panels = [
      for panel in local.dashboard.panels : merge(panel, {
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch.uid
        }
      })
    ]
  }))
}

resource "grafana_organization_preferences" "home_dashboard" {
  count = var.set_as_home_dashboard ? 1 : 0

  home_dashboard_uid = grafana_dashboard.app_overview.uid
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "CloudWatch"

  json_data_encoded = jsonencode({
    authType      = "default"
    defaultRegion = var.dashboard_region
  })
}

locals {
  app_log_group_name = "/aws/containerinsights/${var.cluster_name}/application"
  app_log_group_arn  = "arn:aws:logs:${var.dashboard_region}:${var.account_id}:log-group:${local.app_log_group_name}:*"
  app_log_groups = [{
    arn       = local.app_log_group_arn
    name      = local.app_log_group_name
    accountId = var.account_id
  }]

  explore_logs_query = urlencode(jsonencode({
    datasource = "CloudWatch"
    queries = [{
      queryMode = "Logs"
      region    = var.dashboard_region
      logGroups = [{
        name = local.app_log_group_name
      }]
      queryLanguage = "CWLI"
      expression    = "fields @timestamp, @message | filter @message like /\"event\":\"http_request\"/ | sort @timestamp desc | limit 200"
    }]
    range = {
      from = "now-1h"
      to   = "now"
    }
  }))

  dashboard = {
    id            = null
    uid           = var.dashboard_uid
    title         = var.dashboard_title
    schemaVersion = 39
    version       = 1
    refresh       = "30s"
    timezone      = "browser"
    editable      = true
    tags          = ["eks", "cloudwatch", "saas", var.app_name]
    links = [
      {
        title       = "Open App Logs (Explore)"
        url         = "/explore?left=${local.explore_logs_query}"
        targetBlank = false
      },
      {
        title       = "Open Traces (Explore)"
        url         = "/explore"
        targetBlank = false
      }
    ]
    panels = [
      {
        type  = "timeseries"
        title = "Node CPU Utilization (%)"
        gridPos = {
          h = 8
          w = 8
          x = 0
          y = 0
        }
        datasource = "CloudWatch"
        targets = [{
          namespace  = "ContainerInsights"
          metricName = "node_cpu_utilization"
          dimensions = {
            ClusterName = var.cluster_name
          }
          region           = var.dashboard_region
          period           = ""
          statistic        = "Average"
          matchExact       = true
          queryMode        = "Metrics"
          metricEditorMode = 0
          metricQueryType  = 0
          refId            = "A"
        }]
      },
      {
        type  = "timeseries"
        title = "Node Memory Utilization (%)"
        gridPos = {
          h = 8
          w = 8
          x = 8
          y = 0
        }
        datasource = "CloudWatch"
        targets = [{
          namespace  = "ContainerInsights"
          metricName = "node_memory_utilization"
          dimensions = {
            ClusterName = var.cluster_name
          }
          region           = var.dashboard_region
          period           = ""
          statistic        = "Average"
          matchExact       = true
          queryMode        = "Metrics"
          metricEditorMode = 0
          metricQueryType  = 0
          refId            = "A"
        }]
      },
      {
        type  = "timeseries"
        title = "Node Count (Saturation Proxy)"
        gridPos = {
          h = 8
          w = 8
          x = 16
          y = 0
        }
        datasource = "CloudWatch"
        targets = [{
          namespace  = "ContainerInsights"
          metricName = "cluster_node_count"
          dimensions = {
            ClusterName = var.cluster_name
          }
          region           = var.dashboard_region
          period           = ""
          statistic        = "Average"
          matchExact       = true
          queryMode        = "Metrics"
          metricEditorMode = 0
          metricQueryType  = 0
          refId            = "A"
        }]
      },
      {
        type  = "timeseries"
        title = "Overall Traffic (Requests/min)"
        gridPos = {
          h = 9
          w = 12
          x = 0
          y = 8
        }
        datasource = "CloudWatch"
        targets = [{
          queryMode        = "Logs"
          metricEditorMode = 0
          metricQueryType  = 0
          region           = var.dashboard_region
          logGroups        = local.app_log_groups
          queryLanguage    = "CWLI"
          expression       = "fields @timestamp, @message | filter @message like /\"event\":\"http_request\"/ | stats count(*) as requests by bin(1m)"
          refId            = "A"
        }]
      },
      {
        type  = "timeseries"
        title = "Latency P95 by URL (ms)"
        gridPos = {
          h = 9
          w = 12
          x = 12
          y = 8
        }
        datasource = "CloudWatch"
        targets = [{
          queryMode        = "Logs"
          metricEditorMode = 0
          metricQueryType  = 0
          region           = var.dashboard_region
          logGroups        = local.app_log_groups
          queryLanguage    = "CWLI"
          expression       = "fields @timestamp, @message | filter @message like /\"event\":\"http_request\"/ | parse @message /\"path\":\"(?<path>[^\"]+)\"/ | parse @message /\"duration_ms\":(?<duration_ms>[0-9.]+)/ | stats pct(duration_ms,95) as p95_ms by path, bin(1m)"
          refId            = "A"
        }]
      },
      {
        type  = "table"
        title = "Traffic by URL"
        gridPos = {
          h = 9
          w = 8
          x = 0
          y = 17
        }
        datasource = "CloudWatch"
        targets = [{
          queryMode        = "Logs"
          metricEditorMode = 0
          metricQueryType  = 0
          region           = var.dashboard_region
          logGroups        = local.app_log_groups
          queryLanguage    = "CWLI"
          expression       = "fields @message | filter @message like /\"event\":\"http_request\"/ | parse @message /\"path\":\"(?<path>[^\"]+)\"/ | stats count(*) as requests by path | sort requests desc | limit 20"
          refId            = "A"
        }]
      },
      {
        type  = "table"
        title = "Response Codes by URL"
        gridPos = {
          h = 9
          w = 8
          x = 8
          y = 17
        }
        datasource = "CloudWatch"
        targets = [{
          queryMode        = "Logs"
          metricEditorMode = 0
          metricQueryType  = 0
          region           = var.dashboard_region
          logGroups        = local.app_log_groups
          queryLanguage    = "CWLI"
          expression       = "fields @message | filter @message like /\"event\":\"http_request\"/ | parse @message /\"path\":\"(?<path>[^\"]+)\"/ | parse @message /\"status\":(?<status>\\d+)/ | stats count(*) as requests by path, status | sort path asc, status asc | limit 100"
          refId            = "A"
        }]
      },
      {
        type  = "table"
        title = "Golden Signals Snapshot"
        gridPos = {
          h = 9
          w = 8
          x = 16
          y = 17
        }
        datasource = "CloudWatch"
        targets = [{
          queryMode        = "Logs"
          metricEditorMode = 0
          metricQueryType  = 0
          region           = var.dashboard_region
          logGroups        = local.app_log_groups
          queryLanguage    = "CWLI"
          expression       = <<EOT
fields @timestamp, @message
| filter @message like /http_request/
| parse @message /"status":(?<status>\d+)/
| parse @message /"duration_ms":(?<duration_ms>[0-9.]+)/
| filter ispresent(status) and ispresent(duration_ms)
| stats
    count(*) as traffic,
    pct(duration_ms, 95) as latency_p95_ms,
    sum(if(status >= 500, 1, 0)) as errors_5xx
  by bin(1m)
EOT
          refId            = "A"
        }]
      }
    ]
  }
}
