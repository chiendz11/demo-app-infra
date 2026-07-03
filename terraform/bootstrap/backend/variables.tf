variable "region" {
  description = "AWS region where the Terraform state bucket is created."
  type        = string
  default     = "ap-southeast-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket used for Terraform remote state."
  type        = string
  default     = "demo-app-infra-tfstate-980794397912-ap-southeast-1"
}

variable "owner" {
  description = "Owner tag applied to backend resources."
  type        = string
  default     = "Bui Anh Chien"
}

