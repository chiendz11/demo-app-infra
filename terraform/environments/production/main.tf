data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "main" {
  name         = local.normalized_root_domain
  private_zone = false
}

locals {
  normalized_root_domain = trimsuffix(lower(trimspace(var.root_domain)), ".")
  normalized_subdomain   = trimsuffix(lower(trimspace(var.app_subdomain)), ".")
  application_domain = (
    local.normalized_subdomain == ""
    ? local.normalized_root_domain
    : "${local.normalized_subdomain}.${local.normalized_root_domain}"
  )

  common_tags = {
    Project     = var.project_name
    Environment = "production"
    ManagedBy   = "terraform"
    Owner       = var.owner
  }

  public_subnets = {
    public-a = {
      cidr = "10.30.1.0/24"
      az   = data.aws_availability_zones.available.names[0]
    }

    public-b = {
      cidr = "10.30.2.0/24"
      az   = data.aws_availability_zones.available.names[1]
    }
  }

  private_subnet = {
    cidr = "10.30.11.0/24"
    az   = data.aws_availability_zones.available.names[0]
  }

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y docker nginx

    install -d -m 0755 /etc/docker

    cat > /etc/docker/daemon.json <<'DOCKER'
    {
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
    }
    DOCKER

    systemctl enable --now docker
    usermod -aG docker ec2-user

    cat > /etc/nginx/conf.d/demo-app.conf <<'NGINX'
    server {
      listen ${var.app_port} default_server;
      server_name _;

      location = /health {
        default_type text/plain;
        return 200 "ok\n";
      }

      location / {
        root /usr/share/nginx/html;
        index index.html;
      }
    }
    NGINX

    cat > /usr/share/nginx/html/index.html <<'HTML'
    ${var.project_name} is ready for the first container deployment
    HTML

    systemctl enable --now nginx
    systemctl enable --now amazon-ssm-agent || true
  EOF
}

module "network" {
  source = "../../modules/network"

  project_name           = var.project_name
  vpc_cidr               = var.vpc_cidr
  public_subnets         = local.public_subnets
  private_subnet         = local.private_subnet
  nat_gateway_subnet_key = "public-a"
  tags                   = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.private_subnet_id
  public_subnet_ids = values(module.network.public_subnet_ids)
  instance_type     = var.instance_type
  app_port          = var.app_port
  health_check_path = "/health"
  domain_name       = local.application_domain
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  user_data         = local.user_data
  tags              = local.common_tags
}
