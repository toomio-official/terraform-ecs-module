# Terraform ECS Module

This Terraform module provisions an VPC, ECS and ALB and related AWS resources for deploying the Toomio backend application.

## Description

This module sets up the following AWS resources:

- IAM Roles and Policies
- VPC and Subnets
- ECS Cluster
- ECS Task Definition
- ECS Service
- Application Load Balancer
- Security Groups
- CloudWatch Log Group
- S3 Bucket
- DynamoDB Table

The module is designed to deploy a containerized backend application on AWS ECS using Fargate launch type.

## Inputs

| Name                | Description                | Type     | Required |
| ------------------- | -------------------------- | -------- | :------: |
| `backend_app_image` | Backend Docker image       | `string` |   Yes    |
| `acm_arn`           | ACM ARN for HTTPS listener | `string` |   Yes    |

## Outputs

| Name      | Description                   |
| --------- | ----------------------------- |
| `alb_url` | Application Load Balancer URL |

## Notes

- The module uses an S3 backend for storing Terraform state.
- The ECS task is configured to use Fargate.
- The module creates a CloudWatch log group for the ECS task with a 14-day retention period.
- The VPC is created with public subnets in three availability zones in the us-east-1 region.
- The ALB security group allows inbound traffic on ports 80 and 443 from anywhere.
