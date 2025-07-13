provider "aws" {
  region = "us-east-2"
}

locals {
  vpc_id = "vpc-0a691b1cda1dea4be"
  public_subnet_ids = [
    "subnet-09a9b4fe4e74051b3",
    "subnet-05860172a9327d826"
  ]
}
#resource "aws_vpc" "main" {
 # cidr_block           = "10.0.0.0/16"
  #enable_dns_hostnames = true
 # enable_dns_support   = true

 # tags = {
 #   Name = "main-vpc"
#  }
#}

#resource "aws_subnet" "public" {
  #count                   = 2
 # vpc_id                  = local.vpc_id
 # cidr_block              = "10.0.${count.index + 1}.0/24"
  #availability_zone       = element(["us-east-2a", "us-east-2b"], count.index)
  #map_public_ip_on_launch = true

  #tags = {
 #   Name = "public-subnet-${count.index + 1}"
#  }
#}

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = local.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lb_sg" {
  name        = "lb-security-group"
  description = "Allow HTTP inbound traffic"
  vpc_id      = local.vpc_id

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
    Name = "lb-security-group"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow HTTP and SSH to EC2"
  vpc_id      = local.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

resource "aws_lb" "application_lb" {
  name               = "HaybLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = local.public_subnet_ids[*]
  enable_deletion_protection = false

  tags = {
    Name = "HaybLB"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name = "HaybLB-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "web-target-group"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0d1b5a8c13042c939"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "aws-key-shods"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = local.public_subnet_ids[0]
  user_data              = file("user_data.sh")

  tags = {
    Name = "WebServer"
  }
}

resource "aws_lb_target_group_attachment" "web_instance_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

output "load_balancer_dns" {
  value       = aws_lb.application_lb.dns_name
  description = "The DNS name of the load balancer"
}

output "ec2_instance_id" {
  value       = aws_instance.web_server.id
  description = "The ID of the EC2 instance"
}

output "ec2_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP of the EC2 instance"
}