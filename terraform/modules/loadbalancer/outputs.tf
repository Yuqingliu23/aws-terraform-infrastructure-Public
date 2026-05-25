# terraform/modules/loadbalancer/outputs.tf

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.loadbalancer_api_nlb.dns_name
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.loadbalancer_api_nlb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.loadbalancer_nlb_tg.arn
}

output "web_instance_ids" {
  description = "List of EC2 instance IDs for web servers"
  value       = aws_instance.loadbalancer_web_servers[*].id
}

output "web_lb_security_group_id" {
  description = "ID of the security group for web servers"
  value       = aws_security_group.loadbalancer_web_lb.id
}

output "nlb_security_group_id" {
  description = "ID of the security group for the Network Load Balancer"
  value       = aws_security_group.loadbalancer_nlb_sg.id
}

output "api_fqdn" {
  description = "Fully qualified domain name for the API endpoint"
  value       = "api.${var.domain_name}"
}
