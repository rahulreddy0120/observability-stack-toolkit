resource "kubernetes_secret" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = var.namespace
  }

  data = {
    "alertmanager.yml" = yamlencode({
      global = {
        resolve_timeout = "5m"
      }
      route = {
        receiver   = "default"
        group_by   = ["alertname", "cluster", "service"]
        group_wait = "30s"
        routes = concat(
          var.pagerduty_key != "" ? [{
            match    = { severity = "critical" }
            receiver = "pagerduty"
          }] : [],
          [{
            match    = { severity = "warning" }
            receiver = "slack-warning"
          }]
        )
      }
      receivers = concat(
        [{ name = "default", slack_configs = [{
          api_url    = var.slack_webhook_url
          channel    = var.slack_channel
          send_resolved = true
        }]}],
        var.pagerduty_key != "" ? [{
          name = "pagerduty"
          pagerduty_configs = [{
            routing_key = var.pagerduty_key
            severity    = "critical"
          }]
        }] : [],
        [{
          name = "slack-warning"
          slack_configs = [{
            api_url = var.slack_webhook_url
            channel = var.slack_warning_channel
          }]
        }]
      )
    })
  }
}
