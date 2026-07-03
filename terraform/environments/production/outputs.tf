output "vpc_id" {
  description = "ID of the production VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB."
  value       = module.network.public_subnet_ids
}

output "private_subnet_id" {
  description = "Private subnet ID used by the application EC2 instance."
  value       = module.network.private_subnet_id
}

output "nat_gateway_id" {
  description = "ID of the production NAT Gateway."
  value       = module.network.nat_gateway_id
}

output "instance_id" {
  description = "ID of the private application EC2 instance."
  value       = module.compute.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the application EC2 instance."
  value       = module.compute.private_ip
}

output "alb_dns_name" {
  description = "AWS-generated DNS name of the ALB."
  value       = module.compute.alb_dns_name
}

output "application_url" {
  description = "Public HTTPS URL of the application."
  value       = module.compute.application_url
}

output "certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = module.compute.certificate_arn
}

output "root_domain" {
  description = "Root domain discovered in Route 53."
  value       = local.normalized_root_domain
}

output "hosted_zone_id" {
  description = "ID of the Route 53 public hosted zone."
  value       = data.aws_route53_zone.main.zone_id
}

output "instance_role_arn" {
  description = "IAM role ARN attached to the private EC2 instance."
  value       = module.compute.instance_role_arn
}

output "app_deploy_role_arn" {
  description = "IAM role ARN assumed by the demo-app-ci production deployment workflow."
  value       = aws_iam_role.app_deploy.arn
}
