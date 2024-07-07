output "namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "thanos_bucket" {
  value = aws_s3_bucket.thanos.id
}
