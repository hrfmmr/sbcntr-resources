locals {
  db_parameters = {
    DB_USERNAME = var.db_credentials.username,
    DB_PASSWORD = var.db_credentials.password,
  }
}
