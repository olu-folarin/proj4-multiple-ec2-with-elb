output "aws_instances" {
  value = aws_instance.http_servers
}

output "security_group" {
  value = aws_security_group.security_group
}