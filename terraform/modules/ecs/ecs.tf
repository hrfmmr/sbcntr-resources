# CloudWatch
resource "aws_cloudwatch_log_group" "sbcntr" {
  for_each = {
    frontend_task_def = local.task_def.frontend
    backend_task_def  = local.task_def.backend
  }

  name = each.value.cwlogs_group
}

# IAM
resource "aws_iam_role" "task_exec" {
  name               = "sbcntr-task-exec-role"
  assume_role_policy = file(var.ecs_task_trust_policy)
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.task_exec.id
}

# ECS
resource "aws_ecs_task_definition" "sbcntr" {
  for_each = {
    frontend = local.task_def.frontend
    backend  = local.task_def.backend
  }

  family = each.value.name
  container_definitions = templatefile(each.value.container_def_file, {
    container_name = each.value.container_name
    image          = each.value.image_url
    awslogs-group  = each.value.cwlogs_group
    awslogs-region = var.aws_region
    awslogs-prefix = each.value.cwlogs_prefix
  })

  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.task_exec.arn

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_cluster" "sbcntr_backend" {
  name = var.cluster_def.backend.name
}


resource "aws_ecs_service" "sbcntr_backend" {
  name            = local.service_def.backend.name
  cluster         = local.service_def.backend.cluster_name
  task_definition = aws_ecs_task_definition.sbcntr["backend"].arn

  desired_count = local.service_def.common.desired_count

  launch_type = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.sbcntr_sg_container.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_blue.arn
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
