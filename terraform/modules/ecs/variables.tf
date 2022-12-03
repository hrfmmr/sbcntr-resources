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
variable "ecs_task_trust_policy" {
  type    = string
  default = "./modules/ecs/files/iam_policy/ecs_task_trust_policy.json"
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

locals {
  task_def = {
    frontend = {
      name               = "sbcntr-frontend-def"
      container_def_file = "./modules/ecs/files/ecs_task/ecs_task_frontend.json"
      container_name     = "app"
      image_url          = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sbcntr-frontend:v1"
      cwlogs_group       = "/ecs/sbcntr-frontend-def"
      cwlogs_prefix      = "ecs"
    }

    backend = {
      name               = "sbcntr-backend-def"
      container_def_file = "./modules/ecs/files/ecs_task/ecs_task_backend.json"
      container_name     = "app"
      image_url          = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sbcntr-backend:v1"
      cwlogs_group       = "/ecs/sbcntr-backend-def"
      cwlogs_prefix      = "ecs"
    }
  }

  service_def = {
    common = {
      desired_count = 2
    }
    frontend = {
      name           = "sbcntr-ecs-frontend-service"
      cluster_name   = var.cluster_def.frontend.name
      container_name = "app"
    }
    backend = {
      name           = "sbcntr-ecs-backend-service"
      cluster_name   = var.cluster_def.backend.name
      container_name = "app"
    }
  }
}
