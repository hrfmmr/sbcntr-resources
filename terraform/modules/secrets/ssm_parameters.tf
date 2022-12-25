resource "aws_ssm_parameter" "sbcntr_ssm_param_db" {
  for_each = local.db_parameters
  name     = "/sbcntr/db/${each.key}"
  type     = "SecureString"
  value    = each.value
}

data "aws_ssm_parameters_by_path" "sbcntr_params_db_credentials" {
  path = "/sbcntr/db"
  depends_on = [
    aws_ssm_parameter.sbcntr_ssm_param_db
  ]
}
