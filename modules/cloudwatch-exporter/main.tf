resource "helm_release" "cloudwatch_exporter" {
  name       = "cloudwatch-exporter"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-cloudwatch-exporter"

  values = [
    yamlencode({
      aws = { region = var.aws_region }
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = var.iam_role_arn
        }
      }
      config = yamlencode({
        region = var.aws_region
        metrics = [for ns in var.metrics : {
          aws_namespace  = ns
          aws_dimensions = lookup(local.dimension_map, ns, [])
          aws_statistics = ["Average", "Maximum", "p99"]
        }]
      })
    })
  ]
}

locals {
  dimension_map = {
    "AWS/EC2"  = ["InstanceId"]
    "AWS/RDS"  = ["DBInstanceIdentifier"]
    "AWS/ECS"  = ["ClusterName", "ServiceName"]
    "AWS/ELB"  = ["LoadBalancerName"]
    "AWS/Lambda" = ["FunctionName"]
  }
}
