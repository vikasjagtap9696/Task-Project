locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    app_port       = var.app_port
    app_source_b64 = filebase64("${path.module}/../../intern-task-app/app/app.py")
    dockerfile_b64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
    ssh_cidr       = var.ssh_cidr
  })
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.internet_cidr
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "instance" {
  name        = "${var.name_prefix}-instance"
  description = "Only restricted SSH and the application port"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the caller-provided network"
    protocol    = "tcp"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Intern task application"
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = [var.internet_cidr]
  }

  egress {
    description = "Required outbound access for package and image installation"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.internet_cidr]
  }

  tags = {
    Name = "${var.name_prefix}-instance"
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = true
  user_data                   = local.user_data
  user_data_replace_on_change = false

  tags = {
    Name = "${var.name_prefix}-app"
  }
}
