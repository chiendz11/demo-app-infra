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
  default     = "t3.micro"
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
