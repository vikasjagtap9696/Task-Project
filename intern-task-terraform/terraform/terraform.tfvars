# Replace this documentation CIDR with your current public IP/CIDR before apply.
aws_region         = "ap-south-1"
ami_id             = "ami-0866a3c8686eaeeba"
instance_type      = "t3.micro"
ssh_cidr           = "203.0.113.0/24"
app_port           = 8080
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
name_prefix        = "intern-task"
internet_cidr      = "0.0.0.0/0"
ssh_port           = 22
