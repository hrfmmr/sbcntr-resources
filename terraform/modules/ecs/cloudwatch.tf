# CloudWatch
resource "aws_cloudwatch_log_group" "sbcntr" {
  for_each = {
    frontend_task = local.frontend_def.cwlogs_group
    backend_task  = local.backend_def.cwlogs_group
  }

  name = each.value
}

resource "aws_cloudwatch_log_group" "sbcntr_firelens_container" {
  name = local.backend_def.cwlogs_group_firelens
}
