variable "mysql_ami" {
  description = "AMI ID for MySQL instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where MySQL instance will be launched"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs for MySQL instance"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for MySQL instance, including CloudWatch Agent configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for MySQL instance"
  type        = map(string)
  default     = null
}

variable "key_name" {
  description = "SSH key name for MySQL instance"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile for MySQL instance"
  type        = string
  default     = null
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for CloudWatch Agent credentials"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for CloudWatch Agent credentials"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region for CloudWatch Agent credentials"
  type        = string
  default     = "us-east-2"
}
