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
    condition = (
      can(cidrhost(var.ssh_cidr, 0)) &&
      can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}/[0-9]{1,2}$", var.ssh_cidr)) &&
      cidrnetmask(var.ssh_cidr) != "0.0.0.0"
    )
    error_message = "ssh_cidr must be a valid, non-world-open IPv4 CIDR."
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
