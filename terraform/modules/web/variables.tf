variable "ami_id" {
  description = "AMI ID for web instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for web instance"
  type        = string
}

variable "security_groups" {
  description = "Security group IDs for web instance"
  type        = list(string)
}

variable "mysql_ip" {
  description = "mysql IP of MySQL instance"
  type        = string
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
  description = "Secret key for webapp"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of existing EC2 Key Pair"
  type        = string
}

variable "user_data" {
  description = "User data script for web instance, including CloudWatch Agent configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for web instance"
  type        = map(string)
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile for web instance"
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