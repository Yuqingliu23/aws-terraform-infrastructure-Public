output "webapp_public_ip" {
  value       = module.loadbalancer.web_instance_ids
  description = "IDs of the web server instances"
}

# Load balancer outputs
output "nlb_dns_name" {
  value       = module.loadbalancer.nlb_dns_name
  description = "DNS name of the Network Load Balancer"
}

output "api_fqdn" {
  value       = module.loadbalancer.api_fqdn
  description = "Fully qualified domain name for the API endpoint"
}

output "web_instance_ids" {
  value       = module.loadbalancer.web_instance_ids
  description = "web instance ids"
}
