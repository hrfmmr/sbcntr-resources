# Network
variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_ingress_source_security_groups" {
  type = list(string)
}

# DB
variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_pass" {
  type = string
}

locals {
  db = {
    name     = var.db_name
    username = var.db_username
    pass     = var.db_pass
  }
}
