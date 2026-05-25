# terraform/modules/loadbalancer/main.tf

# Create security group for NLB
resource "aws_security_group" "loadbalancer_nlb_sg" {
  name        = "loadbalancer-nlb-sg"
  description = "Security group for Network Load Balancer"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from the internet (TCP port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-nlb-sg"
  }
}

# Update EC2 instance security group to allow traffic from NLB security group
resource "aws_security_group" "loadbalancer_web_lb" {
  name        = "loadbalancer-web-lb-sg"
  description = "Security Group for Web servers behind load balancer"
  vpc_id      = var.vpc_id

  # Allow TCP port 8080 traffic from NLB security group (health check)
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_nlb_sg.id]
  }

  # Maintain SSH access for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-web-lb-sg"
  }
}

# Create Network Load Balancer (NLB)
resource "aws_lb" "loadbalancer_api_nlb" {
  name               = "loadbalancer-api-nlb"
  internal           = false # Internet-facing
  load_balancer_type = "network"
  security_groups    = [aws_security_group.loadbalancer_nlb_sg.id]
  
  # Ensure NLB is deployed in the same availability zone as EC2 instances
  subnets = [var.subnet_id]

  enable_deletion_protection = false
  
  tags = {
    Name = "loadbalancer-api-nlb"
  }
}

# Create target group
resource "aws_lb_target_group" "loadbalancer_nlb_tg" {
  name        = "loadbalancer-nlb-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  # Configure health check
  health_check {
    protocol            = "HTTP"
    port                = "8080"
    path                = "/v1/healthcheck"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    interval            = 30
    matcher             = "200-399" # Success status code range
  }
  
  tags = {
    Name = "loadbalancer-nlb-tg"
  }
}

# Create listener
resource "aws_lb_listener" "loadbalancer_front_end" {
  load_balancer_arn = aws_lb.loadbalancer_api_nlb.arn
  port              = 80
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loadbalancer_nlb_tg.arn
  }
}

# Create EC2 instances
resource "aws_instance" "loadbalancer_web_servers" {
  count                  = 3
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.loadbalancer_web_lb.id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "loadbalancer-web-server-${count.index + 1}",
    Environment = "production",
    Managed_by  = "terraform",
  }

  # Set user data, including environment variable configuration
  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Configure application environment variables
    echo "DB_HOST='${var.mysql_ip}'" >> /opt/webapp/.env
    echo "DB_PORT=3306" >> /opt/webapp/.env
    echo "DB_USER='${var.db_user}'" >> /opt/webapp/.env
    echo "DB_PASSWORD='${var.db_password}'" >> /opt/webapp/.env
    echo "DB_NAME=recommend1" >> /opt/webapp/.env
    echo "WEBAPP_SECRET_KEY='${var.webapp_secret_key}'" >> /opt/webapp/.env

    cat /opt/webapp/.env
    
    # Ensure the application runs on port 8080
    # Modify application configuration (if needed)
    
    # Start application service
    echo "Starting app service on port 8080"
    cd /opt/webapp/ && npm run start &
    
    # Configure AWS credentials (for CloudWatch, etc.)
    mkdir -p /home/ubuntu/.aws
    echo '[default]' > /home/ubuntu/.aws/credentials
    echo "aws_access_key_id=${var.aws_access_key_id}" >> /home/ubuntu/.aws/credentials
    echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /home/ubuntu/.aws/credentials
    echo "region=${var.aws_region}" >> /home/ubuntu/.aws/credentials
    chmod 600 /home/ubuntu/.aws/credentials
    chown -R ubuntu:ubuntu /home/ubuntu/.aws
  EOF

  # Configure metadata service options, allow IMDSv1 fallback
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # Allow IMDSv1 fallback
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  monitoring = true
}

# Register EC2 instances to target group
resource "aws_lb_target_group_attachment" "loadbalancer_test" {
  count            = 3
  target_group_arn = aws_lb_target_group.loadbalancer_nlb_tg.arn
  target_id        = aws_instance.loadbalancer_web_servers[count.index].id
  port             = 8080
}

# Create Route53 DNS record
resource "aws_route53_record" "loadbalancer_api" {
  zone_id = var.route53_zone_id
  name    = "api.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.loadbalancer_api_nlb.dns_name]
}
