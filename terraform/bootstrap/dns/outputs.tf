output "hosted_zone_id" {
  description = "ID of the Route 53 public hosted zone."
  value       = aws_route53_zone.main.zone_id
}

output "root_domain" {
  description = "Normalized root domain managed by the hosted zone."
  value       = trimsuffix(aws_route53_zone.main.name, ".")
}

output "name_servers" {
  description = "Route 53 name servers that must be configured at the external registrar."
  value       = sort(aws_route53_zone.main.name_servers)
}

output "registrar_instructions" {
  description = "Manual step that remains after Terraform creates the hosted zone."
  value       = "Configure the domain registrar to use the name servers from the name_servers output."
}

