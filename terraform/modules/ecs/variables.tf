variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

# Network
variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_egress_id" {
  type = string
}

# Bastion
variable "sg_bastion_id" {
  type = string
}

# CodeDeploy
variable "codedeploy_trust_policy" {
  type    = string
  default = "./modules/ecs/files/iam_policy/codedeploy_trust_policy.json"
}

# ECS
variable "ecs_task_policy" {
  type    = string
  default = "./modules/ecs/files/iam_policy/ecs_task_policy.json"
}

variable "ecs_task_trust_policy" {
  type    = string
  default = "./modules/ecs/files/iam_policy/ecs_task_trust_policy.json"
}

variable "ecs_task_exec_policy" {
  type    = string
  default = "./modules/ecs/files/iam_policy/ecs_task_exec_policy.json"
}

variable "db_name" {
  type = string
}

variable "db_host" {
  type = string
}

variable "cluster_def" {
  type = map(map(string))
  default = {
    frontend = {
      name = "sbcntr-ecs-frontend-cluster"
    }
    backend = {
      name = "sbcntr-ecs-backend-cluster"
    }
  }
}

variable "service_def" {
  type = map(map(string))
  default = {
    frontend = {
      name = "sbcntr-ecs-frontend-service"
    }
    backend = {
      name = "sbcntr-ecs-backend-service"
    }
  }
}

# Log
variable "s3_logs_bucket" {
  type = string
}

variable "s3_logs_bucket_arn" {
  type = string
}

locals {
  frontend_def = {
    cluster_name = var.cluster_def.frontend.name
    service_name = var.service_def.frontend.name
    cwlogs_group = "/ecs/sbcntr-frontend-def"
  }
  backend_def = {
    cluster_name          = var.cluster_def.backend.name
    service_name          = var.service_def.backend.name
    cwlogs_group          = "/ecs/sbcntr-backend-def"
    cwlogs_group_firelens = "/ecs/sbcntr-firelens-container"
    codedeploy_app_name   = "sbcntr-ecs-backend-codedeploy"
    codedeploy_group_name = "sbcntr-ecs-backend-blue-green-deployment-group"
  }
}
