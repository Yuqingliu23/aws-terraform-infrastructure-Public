# terraform/variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "ssh_key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

variable "ssh_key_path" {
  description = "SSH private key path (for remote access)"
  type        = string
  default     = "./keys/ec2_key.pem"
}

variable "mysql_ami" {
  description = "MySQL server AMI ID"
  type        = string
}

variable "web_ami" {
  description = "Web server AMI ID (contains /v2/metadata endpoint implementation)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "recommend1"
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "webapp_secret_key" {
  description = "Web application secret key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "API endpoint domain name"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "ec2_ssh_key_name" {
  description = "EC2 SSH key name"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  default     = "loadbalancer-vpc"
}

variable "mysql_ip" {
  description = "IP address of the MySQL server"
  type        = string
  default     = "10.0.2.10"
}
