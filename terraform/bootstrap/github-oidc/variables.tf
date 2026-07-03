variable "region" {
  description = "AWS region used by the infrastructure workflow."
  type        = string
  default     = "ap-southeast-1"
}

variable "github_owner" {
  description = "GitHub account or organization that owns the infrastructure repository."
  type        = string
  default     = "chiendz11"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the Terraform deployment role."
  type        = string
  default     = "demo-app-infra"
}

variable "github_plan_environment" {
  description = "GitHub Environment used by Terraform plan workflows."
  type        = string
  default     = "infrastructure-plan"
}

variable "github_apply_environment" {
  description = "GitHub Environment used by Terraform apply and destroy workflows."
  type        = string
  default     = "infrastructure"
}

variable "plan_role_name" {
  description = "Name of the read-only IAM role assumed by Terraform plan workflows."
  type        = string
  default     = "demo-app-infra-terraform-plan-role"
}

variable "apply_role_name" {
  description = "Name of the IAM role assumed by Terraform apply workflows."
  type        = string
  default     = "demo-app-infra-terraform-apply-role"
}

variable "managed_resource_prefix" {
  description = "IAM resource name prefix that Terraform is allowed to manage."
  type        = string
  default     = "demo-app-"
}

variable "state_bucket_name" {
  description = "S3 bucket containing the production Terraform state."
  type        = string
  default     = "demo-app-infra-tfstate-980794397912-ap-southeast-1"
}

variable "production_state_key" {
  description = "S3 object key containing the production Terraform state."
  type        = string
  default     = "environments/production.tfstate"
}

variable "owner" {
  description = "Owner tag applied to IAM resources."
  type        = string
  default     = "Bui Anh Chien"
}
