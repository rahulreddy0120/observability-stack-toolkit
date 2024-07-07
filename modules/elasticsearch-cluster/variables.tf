variable "domain_name" { type = string }
variable "engine_version" { type = string; default = "OpenSearch_2.11" }
variable "instance_type" { type = string; default = "r6g.xlarge.search" }
variable "instance_count" { type = number; default = 3 }
variable "master_instance_type" { type = string; default = "m6g.large.search" }
variable "warm_instance_type" { type = string; default = "ultrawarm1.medium.search" }
variable "warm_instance_count" { type = number; default = 2 }
variable "ebs_volume_size" { type = number; default = 500 }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "allowed_cidrs" { type = list(string); default = ["10.0.0.0/8"] }
variable "environment" { type = string; default = "production" }
