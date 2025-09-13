provider "aws" {
  region = var.aws_region
}

#############################
# Fetch Subnets Dynamically #
#############################
data "aws_subnets" "ecs_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

################
# ECS Cluster  #
################
resource "aws_ecs_cluster" "this" {
  name = "jenkins-ecs-cluster"
}

##########################
# Security Group for ECS #
##########################
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-"
  description = "Allow HTTP traffic for ECS app"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound app traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "ecs-app-sg"
  }
}

##############################
# ECS Task Execution Role    #
##############################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

######################
# ECS Task Definition #
######################
resource "aws_ecs_task_definition" "app" {
  family                   = "my-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = var.app_image
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "ecs-app-task"
  }
}

#################
# ECS Service   #
#################
resource "aws_ecs_service" "app" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.ecs_subnets.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_ecs_task_definition.app, aws_iam_role_policy_attachment.ecs_task_execution_role_attach]

  tags = {
    Name = "ecs-app-service"
  }
}