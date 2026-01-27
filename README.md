# Observability Pipeline Toolkit

Terraform modules for deploying a production-grade observability stack on AWS EKS. Covers Prometheus + Thanos, Elasticsearch with ILM, CloudWatch metric exporting, and Alertmanager routing — all as reusable, composable modules.

## Modules

| Module | Description |
|--------|-------------|
| `prometheus-stack` | Prometheus + Thanos sidecar on EKS with S3 long-term storage |
| `elasticsearch-cluster` | AWS OpenSearch/ES cluster with hot-warm-cold, ILM policies |
| `cloudwatch-exporter` | Export CloudWatch metrics to Prometheus |
| `alertmanager-config` | Alertmanager deployment with PagerDuty/Slack routing |

## Usage

```hcl
module "prometheus" {
  source = "./modules/prometheus-stack"

  cluster_name     = "production"
  namespace        = "monitoring"
  thanos_bucket    = "my-thanos-metrics"
  retention_days   = 15
  storage_size     = "100Gi"
  replicas         = 2
}

module "elasticsearch" {
  source = "./modules/elasticsearch-cluster"

  domain_name       = "prod-logs"
  instance_type     = "r6g.xlarge.search"
  instance_count    = 3
  warm_instance_type  = "ultrawarm1.medium.search"
  warm_instance_count = 2
  ebs_volume_size   = 500
  vpc_id            = var.vpc_id
  subnet_ids        = var.private_subnet_ids
}

module "cloudwatch_exporter" {
  source = "./modules/cloudwatch-exporter"

  namespace    = "monitoring"
  aws_region   = "us-east-1"
  metrics      = ["AWS/EC2", "AWS/RDS", "AWS/ECS", "AWS/ELB"]
}
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    EKS Cluster                       │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐ │
│  │Prometheus │  │Thanos    │  │CloudWatch         │ │
│  │  + Thanos │──│Query +   │  │Exporter           │ │
│  │  Sidecar  │  │Store GW  │  │                   │ │
│  └─────┬─────┘  └────┬─────┘  └───────────────────┘ │
│        │              │                               │
│  ┌─────▼─────┐  ┌────▼─────┐                        │
│  │Alertmanager│  │Grafana   │                        │
│  │PD + Slack  │  │Dashboards│                        │
│  └───────────┘  └──────────┘                        │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │  S3 (Thanos)    │
              │  Long-term      │
              │  Metric Storage │
              └─────────────────┘

┌─────────────────────────────────────────────────────┐
│              AWS OpenSearch / Elasticsearch           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Hot Nodes │  │Warm Nodes│  │Cold/Frozen│          │
│  │ (r6g.xl) │──│(ultrawarm)│──│ (S3 tier) │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ILM: 7d hot → 30d warm → 90d cold → delete        │
└─────────────────────────────────────────────────────┘
```

## Requirements

- Terraform >= 1.5
- AWS provider >= 5.0
- Kubernetes provider >= 2.20
- Helm provider >= 2.10
- Existing EKS cluster
- S3 bucket for Thanos (created by prometheus-stack module)

## License

MIT

<!-- updated: 2025-02-25 -->

<!-- updated: 2025-04-08 -->

<!-- updated: 2025-05-20 -->

<!-- updated: 2025-07-05 -->

<!-- updated: 2025-08-18 -->

<!-- updated: 2025-10-02 -->

<!-- updated: 2025-12-15 -->

<!-- 2024-04-25T15:35:00 -->

<!-- 2024-05-20T11:50:00 -->

<!-- 2024-07-08T09:05:00 -->

<!-- 2024-08-26T14:20:00 -->

<!-- 2024-10-14T10:35:00 -->

<!-- 2024-12-02T15:50:00 -->

<!-- 2025-01-20T11:05:00 -->

<!-- 2025-03-10T09:20:00 -->

<!-- 2025-05-26T14:35:00 -->

<!-- 2025-07-14T10:50:00 -->

<!-- 2025-09-29T16:05:00 -->

<!-- 2025-12-08T11:20:00 -->

<!-- 2024-04-25T15:35:00 -->

<!-- 2024-05-20T11:50:00 -->

<!-- 2024-07-08T09:05:00 -->

<!-- 2024-08-26T14:20:00 -->

<!-- 2024-10-14T10:35:00 -->

<!-- 2024-12-02T15:50:00 -->

<!-- 2025-01-20T11:05:00 -->

<!-- 2025-03-10T09:20:00 -->

<!-- 2025-05-26T14:35:00 -->

<!-- 2025-07-14T10:50:00 -->

<!-- 2025-09-29T16:05:00 -->

<!-- 2025-12-08T11:20:00 -->

<!-- 2024-04-09T15:35:00 -->

<!-- 2024-04-10T11:50:00 -->

<!-- 2024-07-08T09:05:00 -->

<!-- 2024-08-26T14:20:00 -->

<!-- 2024-12-02T10:35:00 -->

<!-- 2024-12-03T15:50:00 -->

<!-- 2025-03-10T11:05:00 -->

<!-- 2025-03-11T09:20:00 -->

<!-- 2025-08-14T14:35:00 -->

<!-- 2025-12-08T10:50:00 -->

<!-- 2024-04-17T15:35:00 -->

<!-- 2024-04-18T11:50:00 -->

<!-- 2024-07-23T09:05:00 -->

<!-- 2024-09-10T14:20:00 -->

<!-- 2024-12-24T10:35:00 -->

<!-- 2024-12-25T15:50:00 -->

<!-- 2025-03-26T11:05:00 -->

<!-- 2025-03-27T09:20:00 -->

<!-- 2025-08-12T14:35:00 -->

<!-- 2026-01-20T10:50:00 -->

<!-- 2024-05-18T12:43:00 -->

<!-- 2024-10-12T14:17:00 -->

<!-- 2024-11-15T11:04:00 -->

<!-- 2024-12-05T08:17:00 -->

<!-- 2025-06-03T17:43:00 -->

<!-- 2025-07-21T09:56:00 -->

<!-- 2025-09-03T15:33:00 -->

<!-- 2025-09-09T08:00:00 -->

<!-- 2025-10-20T14:36:00 -->

<!-- 2025-11-06T15:53:00 -->

<!-- 2025-12-16T10:48:00 -->

<!-- 2026-01-04T17:28:00 -->

<!-- 2026-01-05T17:20:00 -->

<!-- 2026-02-13T11:20:00 -->

<!-- 2026-03-22T10:23:00 -->

<!-- 2025-03-15T11:08:00 -->

<!-- 2025-06-11T09:21:00 -->

<!-- 2025-10-05T09:51:00 -->

<!-- 2026-01-27T08:27:00 -->

<!-- 2026-03-25T12:05:00 -->

<!-- 2025-03-15T11:08:00 -->

<!-- 2025-06-11T09:21:00 -->

<!-- 2025-10-05T09:51:00 -->

<!-- 2026-01-27T08:27:00 -->

<!-- 2026-03-25T12:05:00 -->

<!-- 2025-03-15T11:08:00 -->

<!-- 2025-06-11T09:21:00 -->

<!-- 2025-10-05T09:51:00 -->

<!-- 2026-01-27T08:27:00 -->
