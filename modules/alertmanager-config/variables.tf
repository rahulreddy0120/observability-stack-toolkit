variable "namespace" { type = string; default = "monitoring" }
variable "slack_webhook_url" { type = string; sensitive = true }
variable "slack_channel" { type = string; default = "#alerts-critical" }
variable "slack_warning_channel" { type = string; default = "#alerts-warning" }
variable "pagerduty_key" { type = string; default = ""; sensitive = true }
