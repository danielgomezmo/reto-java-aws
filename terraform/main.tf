
# 1. CONFIGURACION DE TERRAFORM

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}


# 2. UTILIZAR RECURSOS QUE YA EXISTEN

data "aws_ecr_repository" "app" {
  name = "reto-hola-mundo"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}


# 3. CREAR UN GRUPO DE SEGURIDAD

resource "aws_security_group" "web" {
  name        = "reto-hola-mundo-web"
  description = "Acceso web al Hola Mundo"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# 4. PERMISOS PARA ECS

resource "aws_iam_role" "execution" {
  name = "reto-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# 5. REGISTROS DE LA APLICACION

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/reto-hola-mundo"
  retention_in_days = 1
}


# 6. CREAR EL CLUSTER ECS

resource "aws_ecs_cluster" "app" {
  name = "reto-cluster"
}


# 7. DEFINIR NUESTRO CONTENEDOR

resource "aws_ecs_task_definition" "app" {
  family                   = "reto-hola-mundo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.execution.arn

  container_definitions = jsonencode([
    {
      name      = "hola-mundo"
      image     = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


# 8. CREAR EL SERVICIO ECS

resource "aws_ecs_service" "app" {
  name            = "reto-servicio"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.execution,
    aws_vpc_security_group_ingress_rule.web,
    aws_vpc_security_group_egress_rule.outbound
  ]
}


# 9. MOSTRAR INFORMACION AL FINAL

output "cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "image_uri" {
  value = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
}

variable "image_tag" {
  description = "Version de la imagen Docker"
  type        = string
  default     = "1.0"
}