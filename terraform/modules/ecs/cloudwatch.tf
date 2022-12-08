# CloudWatch
resource "aws_cloudwatch_log_group" "sbcntr" {
  for_each = {
    frontend_task_def = local.task_def.frontend
    backend_task_def  = local.task_def.backend
  }

  name = each.value.cwlogs_group
}
