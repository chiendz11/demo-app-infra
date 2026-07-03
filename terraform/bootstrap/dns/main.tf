locals {
  normalized_root_domain = trimsuffix(lower(trimspace(var.root_domain)), ".")
}

resource "aws_route53_zone" "main" {
  name = local.normalized_root_domain

  tags = {
    Name      = local.normalized_root_domain
    Project   = "demo-app-infra"
    Component = "dns"
    ManagedBy = "terraform"
    Owner     = var.owner
  }
}

