# terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# Create VPC and network resources
resource "aws_vpc" "loadbalancer_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = var.vpc_name
  }
}

# Create public subnet for loadbalancer
resource "aws_subnet" "loadbalancer_public_subnet" {
  vpc_id                  = aws_vpc.loadbalancer_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  
  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}

# Create private subnet for MySQL
resource "aws_subnet" "loadbalancer_private_subnet" {
  vpc_id                  = aws_vpc.loadbalancer_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}a"
  
  tags = {
    Name = "${var.vpc_name}-private-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "loadbalancer_igw" {
  vpc_id = aws_vpc.loadbalancer_vpc.id
  
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create Route Table
resource "aws_route_table" "loadbalancer_public_rt" {
  vpc_id = aws_vpc.loadbalancer_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.loadbalancer_igw.id
  }
  
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "loadbalancer_public_rta" {
  subnet_id      = aws_subnet.loadbalancer_public_subnet.id
  route_table_id = aws_route_table.loadbalancer_public_rt.id
}

# Security group for MySQL
resource "aws_security_group" "loadbalancer_mysql_sg" {
  name        = "loadbalancer-mysql-sg"
  description = "Security group for MySQL database"
  vpc_id      = aws_vpc.loadbalancer_vpc.id

  # Allow MySQL traffic from web servers
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow access from within VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-mysql-sg"
  }
}

# MySQL module - Create database instance
module "mysql" {
  source = "./modules/mysql"

  mysql_ami            = var.mysql_ami
  subnet_id            = aws_subnet.loadbalancer_private_subnet.id
  security_groups      = [aws_security_group.loadbalancer_mysql_sg.id]
  key_name             = var.ssh_key_name
  aws_access_key_id    = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region           = var.aws_region
  
  tags = {
    Name = "loadbalancer-mysql-server"
  }
}

# Load balancer module - Create NLB and multiple web instances
module "loadbalancer" {
  source = "./modules/loadbalancer"

  vpc_id           = aws_vpc.loadbalancer_vpc.id
  subnet_id        = aws_subnet.loadbalancer_public_subnet.id
  ami_id           = var.web_ami
  key_name         = var.ssh_key_name
  
  # Database connection info
  mysql_ip      = module.mysql.private_ip
  db_user       = var.db_user
  db_password   = var.db_password

  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region            = var.aws_region
  
  # Route 53 configuration
  route53_zone_id = var.route53_zone_id
  domain_name     = var.domain_name
  
  # If you use IAM instance profile
  iam_instance_profile = var.iam_instance_profile
}
