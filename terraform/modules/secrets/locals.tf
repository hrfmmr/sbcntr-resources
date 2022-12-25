locals {
  db_parameters = {
    DB_USERNAME = var.db_credentials.username,
    DB_PASSWORD = var.db_credentials.password,
  }

  db_secrets = [
    for key, arn in zipmap(
      data.aws_ssm_parameters_by_path.sbcntr_params_db_credentials.names,
      data.aws_ssm_parameters_by_path.sbcntr_params_db_credentials.arns
      ) : {
      name : reverse(split("/", key))[0],
      valueFrom : arn
    }
  ]
}
