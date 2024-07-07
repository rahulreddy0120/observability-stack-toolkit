module "prometheus" {
  source       = "../modules/prometheus-stack"
  cluster_name = "production"
  namespace    = "monitoring"
  thanos_bucket = "prod-thanos-metrics"
  replicas     = 2
  storage_size = "200Gi"
}

module "elasticsearch" {
  source         = "../modules/elasticsearch-cluster"
  domain_name    = "prod-logs"
  instance_type  = "r6g.xlarge.search"
  instance_count = 3
  vpc_id         = var.vpc_id
  subnet_ids     = var.private_subnet_ids
}

module "cloudwatch_exporter" {
  source       = "../modules/cloudwatch-exporter"
  namespace    = module.prometheus.namespace
  iam_role_arn = var.cw_exporter_role_arn
  metrics      = ["AWS/EC2", "AWS/RDS", "AWS/ECS", "AWS/ELB", "AWS/Lambda"]
}

module "alertmanager" {
  source            = "../modules/alertmanager-config"
  namespace         = module.prometheus.namespace
  slack_webhook_url = var.slack_webhook_url
  pagerduty_key     = var.pagerduty_key
}
