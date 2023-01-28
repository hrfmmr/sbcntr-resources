resource "aws_ecs_cluster" "sbcntr_backend" {
  name = local.backend_def.cluster_name
}

resource "null_resource" "ecspresso_backend" {
  triggers = {
    cluster          = aws_ecs_cluster.sbcntr_backend.name
    task_exec_role   = aws_iam_role.sbcntr_task_exec.name
    task_role        = aws_iam_role.sbcntr_task.name
    alb_backend      = aws_lb.internal.arn
    alb_target_group = aws_lb_target_group.internal_blue.arn
  }

  provisioner "local-exec" {
    command     = "ecspresso deploy --no-wait"
    working_dir = "./ecspresso/backend-app"
    environment = {
      # Common
      AWS_ACCOUNT_ID = var.aws_account_id,
      ECS_CLUSTER    = local.backend_def.cluster_name,
      ECS_SERVICE    = local.backend_def.service_name,
      # Task
      CW_LOG_GROUP_ECS_TASK_BACKEND          = aws_cloudwatch_log_group.sbcntr["backend_task"].name,
      CW_LOG_GROUP_ECS_TASK_BACKEND_FIRELENS = aws_cloudwatch_log_group.sbcntr_firelens_container.name,
      S3_BUCKET_ECS_TASK_BACKEND_LOGS        = var.s3_logs_bucket
      ECS_TASK_EXEC_ROLE_ARN                 = aws_iam_role.sbcntr_task_exec.arn,
      ECS_TASK_ROLE_ARN                      = aws_iam_role.sbcntr_task.arn,
      DB_HOST                                = var.db_host,
      DB_NAME                                = var.db_name,
      # Service
      LB_TG_INTERNAL_BLUE = aws_lb_target_group.internal_blue.arn,
      SG_BACKEND_APP      = aws_security_group.sbcntr_sg_container.id,
      VPC_SUBNET_APP_AZ_A = var.subnet_ids[0],
      VPC_SUBNET_APP_AZ_C = var.subnet_ids[1]
      # CodeDeploy
      CODEDEPLOY_APP_NAME   = local.backend_def.codedeploy_app_name,
      CODEDEPLOY_GROUP_NAME = local.backend_def.codedeploy_group_name,
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "aws ecs delete-service --cluster $ECS_CLUSTER --service $ECS_SERVICE --force"
    working_dir = "."
    environment = {
      ECS_CLUSTER = "sbcntr-ecs-backend-cluster",
      ECS_SERVICE = "sbcntr-ecs-backend-service"
    }
  }
}

data "aws_ecs_service" "sbcntr_backend" {
  cluster_arn  = aws_ecs_cluster.sbcntr_backend.arn
  service_name = local.backend_def.service_name

  depends_on = [
    null_resource.ecspresso_backend,
  ]
}
