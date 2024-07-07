variable "namespace" { type = string; default = "monitoring" }
variable "aws_region" { type = string; default = "us-east-1" }
variable "iam_role_arn" { type = string }
variable "metrics" { type = list(string); default = ["AWS/EC2", "AWS/RDS", "AWS/ECS"] }
