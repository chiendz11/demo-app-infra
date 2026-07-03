output "bucket_name" {
  description = "Name of the Terraform remote state bucket."
  value       = aws_s3_bucket.tfstate.bucket
}

output "production_state_key" {
  description = "S3 object key used by the production root module."
  value       = "environments/production.tfstate"
}

