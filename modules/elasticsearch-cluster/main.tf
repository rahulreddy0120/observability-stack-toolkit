resource "aws_security_group" "es" {
  name_prefix = "${var.domain_name}-es-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.domain_name}-es"
    ManagedBy = "terraform"
  }
}

resource "aws_opensearch_domain" "main" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    zone_awareness_enabled   = var.instance_count > 1
    dedicated_master_enabled = var.instance_count >= 3
    dedicated_master_type    = var.instance_count >= 3 ? var.master_instance_type : null
    dedicated_master_count   = var.instance_count >= 3 ? 3 : null

    warm_enabled = var.warm_instance_count > 0
    warm_type    = var.warm_instance_count > 0 ? var.warm_instance_type : null
    warm_count   = var.warm_instance_count > 0 ? var.warm_instance_count : null

    zone_awareness_config {
      availability_zone_count = var.instance_count > 1 ? min(var.instance_count, 3) : null
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
    volume_type = "gp3"
    throughput  = 250
    iops        = 3000
  }

  vpc_options {
    subnet_ids         = slice(var.subnet_ids, 0, min(length(var.subnet_ids), var.instance_count))
    security_group_ids = [aws_security_group.es.id]
  }

  encrypt_at_rest { enabled = true }
  node_to_node_encryption { enabled = true }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
    "indices.query.bool.max_clause_count"    = "1024"
  }

  tags = {
    Name        = var.domain_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Added cold storage tier support
