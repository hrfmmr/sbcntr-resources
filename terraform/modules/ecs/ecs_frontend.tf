## Frontend container
resource "aws_ecs_task_definition" "sbcntr_frontend" {
  depends_on = [
    aws_lb.internal,
  ]

  family = local.task_def.frontend.name
  container_definitions = templatefile(local.task_def.frontend.container_def_file, {
    container_name = local.task_def.frontend.container_name
    image          = local.task_def.frontend.image_url
    environment    = jsonencode(local.task_def.frontend.environment)
    awslogs-group  = local.task_def.frontend.cwlogs_group
    awslogs-region = var.aws_region
    awslogs-prefix = local.task_def.frontend.cwlogs_prefix
  })

  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  network_mode = "awsvpc"

  task_role_arn      = aws_iam_role.sbcntr_task.arn
  execution_role_arn = aws_iam_role.sbcntr_task_exec.arn

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_cluster" "sbcntr_frontend" {
  name = var.cluster_def.frontend.name
}

resource "aws_ecs_service" "sbcntr_frontend" {
  name                   = local.service_def.frontend.name
  cluster                = local.service_def.frontend.cluster_name
  task_definition        = aws_ecs_task_definition.sbcntr_frontend.arn
  desired_count          = local.service_def.common.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = local.service_def.frontend.security_groups
  }

  load_balancer {
    target_group_arn = local.service_def.frontend.lb_target_group_arn
    container_name   = local.service_def.frontend.container_name
    container_port   = 80
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
  }
}

