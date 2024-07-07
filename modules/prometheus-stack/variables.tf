variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "monitoring"
}

variable "thanos_bucket" {
  description = "S3 bucket for Thanos long-term storage"
  type        = string
}

variable "thanos_retention_days" {
  description = "Days to retain metrics in S3"
  type        = number
  default     = 365
}

variable "retention_days" {
  description = "Prometheus local retention"
  type        = number
  default     = 15
}

variable "storage_size" {
  description = "PVC size for Prometheus"
  type        = string
  default     = "100Gi"
}

variable "replicas" {
  description = "Prometheus replicas"
  type        = number
  default     = 2
}

variable "chart_version" {
  description = "kube-prometheus-stack chart version"
  type        = string
  default     = "55.0.0"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "install_grafana" {
  type    = bool
  default = true
}
