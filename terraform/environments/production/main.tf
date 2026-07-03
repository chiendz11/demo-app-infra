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

  observability_compose = base64gzip(
    file("${path.module}/observability/compose.yml")
  )
  prometheus_config = base64gzip(
    templatefile("${path.module}/observability/prometheus.yml.tftpl", {
      application_url = "https://${local.application_domain}/health"
    })
  )
  loki_config = base64gzip(
    file("${path.module}/observability/loki.yml")
  )
  alloy_config = base64gzip(
    templatefile("${path.module}/observability/config.alloy.tftpl", {
      application_url = "https://${local.application_domain}/health"
    })
  )
  grafana_datasources = base64gzip(
    file("${path.module}/observability/grafana-datasources.yml")
  )

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y curl docker nginx openssl

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

    COMPOSE_VERSION="v2.32.4"
    install -d -m 0755 /usr/local/lib/docker/cli-plugins
    curl --fail --location --retry 5 \
      "https://github.com/docker/compose/releases/download/$${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
      --output /usr/local/lib/docker/cli-plugins/docker-compose
    chmod 0755 /usr/local/lib/docker/cli-plugins/docker-compose
    docker compose version

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

    install -d -m 0755 \
      /opt/observability \
      /opt/observability/grafana/provisioning/datasources

    printf '%s' '${local.observability_compose}' \
      | base64 --decode | gzip --decompress \
      > /opt/observability/compose.yml

    printf '%s' '${local.prometheus_config}' \
      | base64 --decode | gzip --decompress \
      > /opt/observability/prometheus.yml

    printf '%s' '${local.loki_config}' \
      | base64 --decode | gzip --decompress \
      > /opt/observability/loki.yml

    printf '%s' '${local.alloy_config}' \
      | base64 --decode | gzip --decompress \
      > /opt/observability/config.alloy

    printf '%s' '${local.grafana_datasources}' \
      | base64 --decode | gzip --decompress \
      > /opt/observability/grafana/provisioning/datasources/datasources.yml

    if [ ! -s /opt/observability/.env ]; then
      umask 077
      printf 'GRAFANA_ADMIN_PASSWORD=%s\n' "$(openssl rand -hex 24)" \
        > /opt/observability/.env
    fi

    chmod 0600 /opt/observability/.env

    cat > /etc/systemd/system/demo-app-observability.service <<'SYSTEMD'
    [Unit]
    Description=Demo app observability stack
    Wants=network-online.target
    After=network-online.target docker.service
    Requires=docker.service

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    WorkingDirectory=/opt/observability
    ExecStart=/usr/bin/docker compose --env-file /opt/observability/.env up -d --remove-orphans
    ExecStop=/usr/bin/docker compose --env-file /opt/observability/.env down
    TimeoutStartSec=0
    Restart=on-failure
    RestartSec=30

    [Install]
    WantedBy=multi-user.target
    SYSTEMD

    systemctl daemon-reload
    systemctl enable --now demo-app-observability.service
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
  root_volume_size  = var.root_volume_size
  app_port          = var.app_port
  health_check_path = "/health"
  domain_name       = local.application_domain
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  user_data         = local.user_data
  tags              = local.common_tags

  depends_on = [module.network]
}
