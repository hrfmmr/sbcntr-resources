## Task
resource "aws_iam_role" "sbcntr_task" {
  name               = "sbcntr-task-role"
  assume_role_policy = file(var.ecs_task_trust_policy)
}

resource "aws_iam_policy" "sbcntr_task" {
  name = "sbcntr-task-policy"
  policy = templatefile(var.ecs_task_policy, {
    s3_logs_bucket_arn = var.s3_logs_bucket_arn
  })
}

resource "aws_iam_role_policy_attachment" "sbcntr_task" {
  policy_arn = aws_iam_policy.sbcntr_task.arn
  role       = aws_iam_role.sbcntr_task.id
}

## Task execution
resource "aws_iam_role" "sbcntr_task_exec" {
  name               = "sbcntr-task-exec-role"
  assume_role_policy = file(var.ecs_task_trust_policy)
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.sbcntr_task_exec.id
}


resource "aws_iam_policy" "sbcntr_task_exec" {
  name   = "sbcntr-task-exec-policy"
  policy = file(var.ecs_task_exec_policy)
}

resource "aws_iam_role_policy_attachment" "sbcntr_task_exec" {
  policy_arn = aws_iam_policy.sbcntr_task_exec.arn
  role       = aws_iam_role.sbcntr_task_exec.id
}
