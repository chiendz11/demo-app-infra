variable "region" {
  description = "AWS region where production resources are created."
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the production VPC."
  type        = string
  default     = "10.30.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "project_name" {
  description = "Project name used to name production resources."
  type        = string
  default     = "demo-app-prod"
}

variable "instance_type" {
  description = "EC2 instance type used to host the application stack."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Encrypted gp3 root volume size in GiB for application and observability data."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 20
    error_message = "root_volume_size must be at least 20 GiB for metrics and log retention."
  }
}

variable "app_port" {
  description = "Port exposed by the application on the private EC2 instance."
  type        = number
  default     = 8080
}

variable "root_domain" {
  description = "Root domain managed by the Route 53 public hosted zone."
  type        = string

  validation {
    condition = (
      length(trimspace(var.root_domain)) > 0 &&
      !startswith(var.root_domain, "http://") &&
      !startswith(var.root_domain, "https://")
    )
    error_message = "root_domain must be a DNS name without protocol, for example example.com."
  }
}

variable "app_subdomain" {
  description = "Subdomain used by the application. Use an empty string for the zone apex."
  type        = string
  default     = "app"
}

variable "owner" {
  description = "Owner tag applied to production resources."
  type        = string
  default     = "Bui Anh Chien"
}

variable "github_deploy_repository" {
  description = "GitHub repository allowed to assume the application deployment role."
  type        = string
  default     = "chiendz11/demo-app-ci"

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", trimspace(var.github_deploy_repository)))
    error_message = "github_deploy_repository must use the owner/repository format."
  }
}

variable "github_deploy_environment" {
  description = "GitHub Environment used by the production application deployment job."
  type        = string
  default     = "production"
}

variable "github_oidc_provider_arn" {
  description = "ARN exported by the GitHub OIDC bootstrap stack."
  type        = string

  validation {
    condition = can(regex(
      "^arn:[^:]+:iam::[0-9]{12}:oidc-provider/token\\.actions\\.githubusercontent\\.com$",
      trimspace(var.github_oidc_provider_arn),
    ))
    error_message = "github_oidc_provider_arn must be the ARN of the AWS IAM OIDC provider for GitHub Actions."
  }
}

variable "app_deploy_role_name" {
  description = "IAM role assumed by the demo-app production deployment workflow."
  type        = string
  default     = "demo-app-ci-production-deploy-role"
}
