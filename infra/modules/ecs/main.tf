resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family = "ecs-task"


  container_definitions = jsonencode([
    {
      name      = "ecs-health-app"
      image     = var.ecr_uri
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/ecs-health-app"
          "awslogs-region"        = "eu-north-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  memory                   = "512"
  cpu                      = "256"
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/ecs-health-app"
  retention_in_days = 7
}

resource "aws_security_group" "main" {
  name   = "sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  security_group_id            = aws_security_group.main.id
  referenced_security_group_id = var.alb_security_group_id

  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_ecs_service" "main" {
  name            = "Ichigo-ECS-Service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ecs-health-app"
    container_port   = 3000
  }

  network_configuration {
    subnets          = [var.subnet_a_id, var.subnet_b_id]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = true
  }
}
