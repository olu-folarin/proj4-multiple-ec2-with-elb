resource "aws_default_vpc" "default" {

}

# load balancer: separate sec groupfor the c2 instances and the load balancers to prevent people sshing into it.
resource "aws_security_group" "elb_group" {
  name   = "elb_secgroup"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "classic_elb" {
  name            = "elb"
  subnets         = data.aws_subnets.subnet_ids.ids
  security_groups = [aws_security_group.elb_group.id]
  #   get all the ids from values in the aws instances values
  instances = values(aws_instance.http_servers).*.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_security_group" "security_group" {
  name   = "http_servers"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "http_servers_security_group"
  }
}

resource "aws_instance" "http_servers" {
  ami                    = data.aws_ami.regional_ami.id
  key_name               = "ec2-project1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]

  # create an ec2 instance for each subnet
  for_each  = toset(data.aws_subnets.subnet_ids.ids)
  subnet_id = each.value

  tags = {
    name : "http_servers_${each.value}"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      # install httpd/http server
      "sudo yum install httpd -y",
      # start the server
      "sudo service httpd start",
      # copy a file
      "echo Here is a virtual server hosted on aws with an html file on it displaying this message for all to see. The virtual server is at ${self.public_dns}. | sudo tee /var/www/html/index.html"
    ]
  }
}