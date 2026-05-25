# outputs.tf
output "vpc_id" {
  value = local.vpc_id
}

output "public_subnet_id" {
  value = local.public_subnet_id
}

output "private_subnet_id" {
  value = local.private_subnet_id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}
