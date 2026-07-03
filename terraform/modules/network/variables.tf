variable "project_name" {
  description = "Project name used to name network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
}

variable "public_subnets" {
  description = "Public subnets used by the internet-facing ALB."
  type = map(object({
    cidr = string
    az   = string
  }))

  validation {
    condition = (
      length(var.public_subnets) >= 2 &&
      length(distinct([
        for subnet in values(var.public_subnets) : subnet.az
      ])) >= 2
    )
    error_message = "An Application Load Balancer requires at least two public subnets in different Availability Zones."
  }
}

variable "private_subnet" {
  description = "Private subnet used by the application EC2 instance."
  type = object({
    cidr = string
    az   = string
  })
}

variable "nat_gateway_subnet_key" {
  description = "Key of the public subnet where the NAT Gateway is created."
  type        = string
}

variable "tags" {
  description = "Common tags applied to network resources."
  type        = map(string)
  default     = {}
}
