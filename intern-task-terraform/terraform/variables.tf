variable "aws_region" {
  description = "AWS region used for the VPC and instance."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for the selected region."
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "The single CIDR allowed to access SSH. This must be supplied by the caller."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && !endswith(var.ssh_cidr, "/0")
    error_message = "ssh_cidr must be a valid CIDR narrower than 0.0.0.0/0."
  }
}

variable "app_port" {
  description = "TCP port exposed by the intern-task-app container."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535 && floor(var.app_port) == var.app_port
    error_message = "app_port must be an integer between 1 and 65535."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public application subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "name_prefix" {
  description = "Prefix used for AWS resource names and tags."
  type        = string
  default     = "intern-task"
}

variable "internet_cidr" {
  description = "CIDR used for public application access and the default route."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_port" {
  description = "TCP port used for SSH management."
  type        = number
  default     = 22
}
