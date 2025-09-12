provider "aws" {
  region = var.aws_region
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "jenkins-ecs-cluster"
}

# Security Group for ECS tasks (forces unique name with random suffix)
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-" # avoids name conflict
  description = "Allow HTTP traffic for ECS app"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound app traffic"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-app-sg"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "my-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "app"
    image = var.app_image
    portMappings = [{
      containerPort = 9000
      hostPort      = 9000
      protocol      = "tcp"
    }]
  }])

  tags = {
    Name = "ecs-app-task"
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_ecs_task_definition.app]

  tags = {
    Name = "ecs-app-service"
  }
}
