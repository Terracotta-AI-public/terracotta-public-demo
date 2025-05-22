variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the subnet"
  type        = string
  default     = "us-west-2a"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID for us-west-2"
  type        = string
  default     = "ami-0735c191cf914754d"  # Amazon Linux 2023 AMI in us-west-2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_secondary" {
  description = "EC2 instance type for secondary instance"
  type        = string
  default     = "t2.micro"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "BasicTable"
}
