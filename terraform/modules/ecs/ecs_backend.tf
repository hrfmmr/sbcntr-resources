## Backend container
resource "aws_ecs_task_definition" "sbcntr_backend" {
  family = local.task_def.backend.name
  container_definitions = templatefile(local.task_def.backend.container_def_file, {
    container_name = local.task_def.backend.container_name
    image          = local.task_def.backend.image_url
    awslogs-group  = local.task_def.backend.cwlogs_group
    awslogs-region = var.aws_region
    awslogs-prefix = local.task_def.backend.cwlogs_prefix
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

resource "aws_ecs_cluster" "sbcntr_backend" {
  name = var.cluster_def.backend.name
}


resource "aws_ecs_service" "sbcntr_backend" {
  name                   = local.service_def.backend.name
  cluster                = local.service_def.backend.cluster_name
  task_definition        = aws_ecs_task_definition.sbcntr_backend.arn
  desired_count          = local.service_def.common.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = local.service_def.backend.security_groups
  }

  load_balancer {
    target_group_arn = local.service_def.backend.lb_target_group_arn
    container_name   = local.service_def.backend.container_name
    container_port   = 80
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
  }
}
