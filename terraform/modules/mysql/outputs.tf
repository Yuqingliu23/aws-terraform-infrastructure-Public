output "instance_id" {
  value = aws_instance.mysql.id
}

output "private_ip" {
  value = aws_instance.mysql.private_ip
}
