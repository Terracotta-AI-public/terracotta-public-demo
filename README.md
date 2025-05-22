# Terraform AWS Infrastructure

## Overview
This project deploys a secure AWS infrastructure using Terraform, featuring a VPC setup with an EC2 instance and DynamoDB tables. The project includes remote state management using S3 and DynamoDB for state locking.

## Prerequisites
- AWS CLI configured
- Terraform installed
- Environment variables set up in `.env` file:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_DEFAULT_REGION
  - REGION
  - BUCKET_NAME
  - DYNAMODB_TABLE

## Infrastructure Components

### State Management
- **S3 Backend**
  - Bucket: `terracotta-aws-statefile-demo-bucket`
  - State file path: `terraform/state.tfstate`
  - Encryption enabled
- **DynamoDB State Locking**
  - Table: `terracotta-aws-demo-lock-table`

### Networking
- **Amazon VPC**
  - CIDR Block: 10.0.0.0/16
  - DNS support and DNS hostnames enabled
  - Single public subnet (10.0.1.0/24) in us-west-2a
  - Internet Gateway for public internet access
  - Route table configured for public subnet access

### Compute
- **EC2 Instance**
  - Instance Type: t2.micro (configurable)
  - Latest Amazon Linux 2023 AMI (automatically fetched)
  - Deployed in public subnet
  - Auto-assigned public IP
  - Security group configuration:
    - Inbound: SSH (port 22) from any source
    - Outbound: All traffic allowed

### Database
- **DynamoDB Table**
  - Table Name: BasicTable (configurable)
  - Billing Mode: Pay-per-request (On-demand)
  - Primary Key: Id (String)
  - No provisioned capacity (scales automatically)

## Setup Instructions

1. Initialize the backend infrastructure:
```bash
chmod +x scripts/createS3stateDynamodb.sh
./scripts/createS3stateDynamodb.sh
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the infrastructure:
```bash
terraform init
```

## Configuration Variables

All infrastructure configurations can be customized through variables in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| aws_region | AWS region | us-west-2 |
| vpc_cidr | VPC CIDR block | 10.0.0.0/16 |
| public_subnet_cidr | Public subnet CIDR | 10.0.1.0/24 |
| availability_zone | AZ for subnet | us-west-2a |
| instance_type | EC2 instance type | t2.micro |
| dynamodb_table_name | DynamoDB table name | BasicTable |

## Outputs

The infrastructure provides the following outputs:
- VPC ID
- Public Subnet ID
- EC2 Instance Public IP

## Security Features
- VPC isolation with controlled internet access
- Security Groups with principle of least privilege
- Encrypted S3 state storage
- DynamoDB state locking for collaborative work
- Public subnet with internet gateway for EC2 access

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License
[Add your license information here]

## Infrastructure Diagram
