provider "grafana" {
  alias = "cloud"

  cloud_access_policy_token = var.cloud_access_policy_token
}

resource "grafana_apps_productactivation_k8so11yconfig_v1alpha1" "k8s_o11y" {
  count = var.enable_kubernetes_monitoring ? 1 : 0

  provider = grafana.cloud
  enabled  = true

  metadata = {
    uid = "global"
  }
}

resource "grafana_apps_productactivation_appo11yconfig_v1alpha1" "app_o11y" {
  count = var.enable_application_observability ? 1 : 0

  provider = grafana.cloud
  enabled  = true

  metadata = {
    uid = "global"
  }
}

resource "grafana_synthetic_monitoring_installation" "this" {
  count = var.enable_synthetic_monitoring ? 1 : 0

  provider = grafana.cloud
  stack_id = var.grafana_cloud_stack_id

  metrics_publisher_key = var.synthetic_monitoring_metrics_publisher_key
}

provider "grafana" {
  alias = "sm"

  sm_access_token = var.enable_synthetic_monitoring ? grafana_synthetic_monitoring_installation.this[0].sm_access_token : null
}

data "grafana_synthetic_monitoring_probes" "all" {
  count = var.enable_synthetic_monitoring ? 1 : 0

  provider = grafana.sm
}

locals {
  synthetic_probe_ids = var.enable_synthetic_monitoring ? (
    length(var.synthetic_monitoring_public_probe_ids) > 0
    ? var.synthetic_monitoring_public_probe_ids
    : slice(
      [for probe in data.grafana_synthetic_monitoring_probes.all[0].probes : probe.id],
      0,
      min(var.synthetic_monitoring_default_probe_count, length(data.grafana_synthetic_monitoring_probes.all[0].probes)),
    )
  ) : []
}

resource "grafana_synthetic_monitoring_check" "frontend_http" {
  count = var.enable_synthetic_monitoring && var.frontend_synthetic_url != "" ? 1 : 0

  provider = grafana.sm

  job               = "bizcloud-frontend-http"
  target            = var.frontend_synthetic_url
  enabled           = true
  probes            = local.synthetic_probe_ids
  alert_sensitivity = "none"

  settings {
    http {}
  }
}

resource "grafana_synthetic_monitoring_check" "backend_http" {
  count = var.enable_synthetic_monitoring && var.backend_synthetic_url != "" ? 1 : 0

  provider = grafana.sm

  job               = "bizcloud-backend-http"
  target            = var.backend_synthetic_url
  enabled           = true
  probes            = local.synthetic_probe_ids
  alert_sensitivity = "none"

  settings {
    http {}
  }
}
