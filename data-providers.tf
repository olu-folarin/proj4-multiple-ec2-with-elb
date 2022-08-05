data "aws_subnets" "subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

data "aws_ami" "regional_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami_ids" "linux_ids" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amazn2-ami-hvm-*"]
  }
}