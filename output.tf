output "aws_instances" {
  value = aws_instance.http_servers
}

output "security_group" {
  value = aws_security_group.security_group
}

output "http_server_public_dns" {
  value = values(aws_instance.http_servers).*.id
}

output "elb_public_dns" {
  value = aws_elb.classic_elb
}