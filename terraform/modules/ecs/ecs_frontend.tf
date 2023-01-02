resource "aws_ecs_cluster" "sbcntr_frontend" {
  name = local.frontend_def.cluster_name
}

resource "null_resource" "ecspresso_frontend" {
  triggers = {
    cluster          = aws_ecs_cluster.sbcntr_frontend.name
    task_exec_role   = aws_iam_role.sbcntr_task_exec.name
    task_role        = aws_iam_role.sbcntr_task.name
    alb_backend      = aws_lb.internal.dns_name
    alb_target_group = aws_lb_target_group.frontend.arn
  }

  provisioner "local-exec" {
    command     = "ecspresso deploy --debug"
    working_dir = "./ecspresso/frontend-app"
    environment = {
      # Common
      AWS_ACCOUNT_ID = var.aws_account_id,
      ECS_CLUSTER    = local.frontend_def.cluster_name,
      ECS_SERVICE    = local.frontend_def.service_name,
      # Task
      CW_LOG_GROUP_ECS_TASK_FRONTEND = local.frontend_def.cwlogs_group,
      ECS_TASK_EXEC_ROLE_ARN         = aws_iam_role.sbcntr_task_exec.arn,
      ECS_TASK_ROLE_ARN              = aws_iam_role.sbcntr_task.arn,
      NOTIF_SERVICE_HOST             = aws_lb.internal.dns_name,
      APP_SERVICE_HOST               = aws_lb.internal.dns_name,
      DB_HOST                        = var.db_host,
      DB_NAME                        = var.db_name,
      # Service
      LB_TG_FRONTEND      = aws_lb_target_group.frontend.arn,
      SG_FRONTEND_APP     = aws_security_group.sbcntr_sg_front_container.id,
      VPC_SUBNET_APP_AZ_A = var.subnet_ids[0],
      VPC_SUBNET_APP_AZ_C = var.subnet_ids[1]
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "ecspresso scale --tasks 0 && ecspresso delete --force"
    working_dir = "./ecspresso/frontend-app"
    environment = {
      ECS_CLUSTER = "sbcntr-ecs-frontend-cluster",
      ECS_SERVICE = "sbcntr-ecs-frontend-service"
    }
  }
}
