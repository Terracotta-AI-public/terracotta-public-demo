terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # These will be automatically picked up from environment variables
  # AWS_ACCESS_KEY_ID
  # AWS_SECRET_ACCESS_KEY
  # AWS_DEFAULT_REGION
}

# VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "prod-vpc"
    Environment = "production"
    Project     = "terracotta-demo"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name        = "prod-igw"
    Environment = "production"
    Project     = "terracotta-demo"
  }
}

# Public Subnet
resource "aws_subnet" "prod_public_subnet" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name        = "prod-public-subnet-1a"
    Environment = "production"
    Project     = "terracotta-demo"
    Tier        = "public"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "prod_public_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  tags = {
    Name        = "prod-public-route-table"
    Environment = "production"
    Project     = "terracotta-demo"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "prod_public_rt_assoc" {
  subnet_id      = aws_subnet.prod_public_subnet.id
  route_table_id = aws_route_table.prod_public_rt.id
}

# Security Group for Web Servers
resource "aws_security_group" "prod_web_sg" {
  name        = "prod-web-servers-sg"
  description = "Security group for production web servers"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "prod-web-servers-sg"
    Environment = "production"
    Project     = "terracotta-demo"
  }
}

# Data source for the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Primary Web Server
resource "aws_instance" "prod_web_01" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-web-01"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "web-server"
    Backup      = "daily"
  }
}

# Secondary Web Server
resource "aws_instance" "prod_web_02" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type_secondary
  subnet_id                   = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.prod_web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-web-02"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "web-server"
    Backup      = "daily"
  }
}

# Application Server 01
resource "aws_instance" "prod_app_01" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-app-01"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "application-server"
    Backup      = "daily"
  }
}

# Application Server 02
resource "aws_instance" "prod_app_02" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_secondary
  subnet_id              = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-app-02"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "application-server"
    Backup      = "daily"
  }
}

# Database Server 01
resource "aws_instance" "prod_db_01" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-db-01"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "database-server"
    Backup      = "hourly"
  }
}

# Database Server 02 (Standby)
resource "aws_instance" "prod_db_02" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_secondary
  subnet_id              = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-db-02"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "database-server-standby"
    Backup      = "hourly"
  }
}

# Load Balancer / Proxy Server
resource "aws_instance" "prod_lb_01" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "prod-lb-01"
    Environment = "production"
    Project     = "terracotta-demo"
    Role        = "load-balancer"
    Backup      = "daily"
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "prod_user_data" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "prod-user-data-table"
    Environment = "production"
    Project     = "terracotta-demo"
    Backup      = "continuous"
  }
}

# Outputs
output "vpc_id" {
  description = "The ID of the production VPC"
  value       = aws_vpc.prod_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the production public subnet"
  value       = aws_subnet.prod_public_subnet.id
}

output "web_server_01_ip" {
  description = "Public IP of the primary web server"
  value       = aws_instance.prod_web_01.public_ip
}

output "web_server_02_ip" {
  description = "Public IP of the secondary web server"
  value       = aws_instance.prod_web_02.public_ip
}

output "app_server_01_ip" {
  description = "Public IP of the primary application server"
  value       = aws_instance.prod_app_01.public_ip
}

output "app_server_02_ip" {
  description = "Public IP of the secondary application server"
  value       = aws_instance.prod_app_02.public_ip
}

output "database_server_01_ip" {
  description = "Public IP of the primary database server"
  value       = aws_instance.prod_db_01.public_ip
}

output "database_server_02_ip" {
  description = "Public IP of the standby database server"
  value       = aws_instance.prod_db_02.public_ip
}

output "load_balancer_ip" {
  description = "Public IP of the load balancer"
  value       = aws_instance.prod_lb_01.public_ip
}

output "dynamodb_table_name" {
  description = "Name of the production DynamoDB table"
  value       = aws_dynamodb_table.prod_user_data.name
}

output "security_group_id" {
  description = "ID of the production web servers security group"
  value       = aws_security_group.prod_web_sg.id
}
