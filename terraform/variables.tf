variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where ECS will run"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "app_image" {
  description = "App image from ECR"
  type        = string
  default     = "414508482017.dkr.ecr.us-east-1.amazonaws.com/node3:latest"
}
variable "app_port" {
  description = "Port on which app container runs"
  type        = number
}

variable "security_group" {
  description = "Security group ID for ECS tasks"
  type        = string
}
