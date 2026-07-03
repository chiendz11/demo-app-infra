output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "terraform_plan_role_arn" {
  description = "Read-only IAM role ARN assumed by Terraform plan workflows."
  value       = aws_iam_role.plan.arn
}

output "terraform_apply_role_arn" {
  description = "IAM role ARN assumed by Terraform apply and destroy workflows."
  value       = aws_iam_role.apply.arn
}
