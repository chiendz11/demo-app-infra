variable "project_name" {
  description = "Project name used to name compute resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where compute resources are created."
  type        = string
}

variable "subnet_id" {
  description = "ID of the private subnet where the EC2 instance is created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing ALB."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB requires at least two public subnet IDs."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "root_volume_size" {
  description = "Size in GiB of the encrypted gp3 root volume."
  type        = number
  default     = 20
}

variable "user_data" {
  description = "Cloud-init shell script executed when the EC2 instance starts."
  type        = string
}

variable "app_port" {
  description = "Port exposed by the application on the EC2 instance."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  default     = "/health"
}

variable "domain_name" {
  description = "Public DNS name used by the application and ACM certificate."
  type        = string
}

variable "route53_zone_id" {
  description = "ID of the public Route 53 hosted zone used for DNS validation."
  type        = string
}

variable "tags" {
  description = "Common tags applied to compute resources."
  type        = map(string)
  default     = {}
}
