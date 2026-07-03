variable "region" {
  description = "AWS region used by the provider. Route 53 itself is global."
  type        = string
  default     = "ap-southeast-1"
}

variable "root_domain" {
  description = "Registered root domain delegated to Route 53, for example example.com."
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

variable "owner" {
  description = "Owner tag applied to the hosted zone."
  type        = string
  default     = "Bui Anh Chien"
}

