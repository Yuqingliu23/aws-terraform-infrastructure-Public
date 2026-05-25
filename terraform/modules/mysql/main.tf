# terraform/modules/mysql/main.tf
resource "aws_instance" "mysql" {
  ami                         = var.mysql_ami
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_groups
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  
  # Set user_data, only containing CloudWatch Agent start command
  user_data = <<-EOF
    #!/bin/bash
    
    # Create ubuntu user AWS credentials directory with valid credentials
    mkdir -p /home/ubuntu/.aws
    echo '[default]' > /home/ubuntu/.aws/credentials
    echo "aws_access_key_id=${var.aws_access_key_id}" >> /home/ubuntu/.aws/credentials
    echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /home/ubuntu/.aws/credentials
    echo "region=${var.aws_region}" >> /home/ubuntu/.aws/credentials
    chmod 600 /home/ubuntu/.aws/credentials
    chown -R ubuntu:ubuntu /home/ubuntu/.aws
    
    # Use sudo to create root AWS credentials with same content
    mkdir -p /root/.aws
    echo '[default]' > /root/.aws/credentials
    echo "aws_access_key_id=${var.aws_access_key_id}" >> /root/.aws/credentials
    echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /root/.aws/credentials
    echo "region=${var.aws_region}" >> /root/.aws/credentials
    chmod 600 /root/.aws/credentials
    
    # Start CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a append-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    sudo systemctl restart amazon-cloudwatch-agent
  EOF

  # Configure metadata service options to allow IMDSv1 fallback
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # Allow IMDSv1 fallback
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tags = var.tags != null ? var.tags : {
    Name = "MySQL-Server"
  }
}