resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "purpose"                      = "observability"
    }
  }
}

resource "aws_s3_bucket" "thanos" {
  bucket = var.thanos_bucket
  tags = {
    Name        = var.thanos_bucket
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "thanos" {
  bucket = aws_s3_bucket.thanos.id

  rule {
    id     = "expire-old-metrics"
    status = "Enabled"
    expiration {
      days = var.thanos_retention_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "thanos" {
  bucket = aws_s3_bucket.thanos.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          replicas         = var.replicas
          retention        = "${var.retention_days}d"
          scrapeInterval   = "30s"
          evaluationInterval = "30s"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = var.storage_size }
                }
              }
            }
          }
          thanos = {
            objectStorageConfig = {
              secret = {
                type = "S3"
                config = {
                  bucket   = aws_s3_bucket.thanos.id
                  endpoint = "s3.${var.aws_region}.amazonaws.com"
                }
              }
            }
          }
        }
      }
      alertmanager = { enabled = true }
      grafana      = { enabled = var.install_grafana }
    })
  ]
}

# Updated chart version for security patch
