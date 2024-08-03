resource "aws_ecs_cluster" "my_cluster" {
  name = local.project_name
}

resource "aws_ecs_task_definition" "backend_task" {
  family                = local.backend_app
  container_definitions = <<DEFINITION
  [
    {
      "name": "${local.backend_app}",
      "image": "${var.backend_app_image}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/toomio-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "true"
        }
      },
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  depends_on = [
    aws_cloudwatch_log_group.backend_log_group
 ]
}

resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = "/ecs/toomio-backend"
  retention_in_days = 14
}

resource "aws_ecs_service" "backend_service" {
  name            = local.backend_app
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.toomio_backend_target_group.arn
    container_name   = aws_ecs_task_definition.backend_task.family
    container_port   = 3000
  }

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

