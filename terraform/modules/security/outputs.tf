output "web_sg_id" {
  value = aws_security_group.web.id
}

output "mysql_sg_id" {
  value = aws_security_group.mysql.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}