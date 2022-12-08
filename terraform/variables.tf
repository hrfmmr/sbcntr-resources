data "aws_caller_identity" "current" {}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "ssh_public_key" {
  type = string
}

variable "bastion_ssh_allowed_ips" {
  type = list(string)
}

variable "ec2_bastion_ami" {
  type = string
}

variable "vpc_interface_endpoints" {
  type = list(string)
  default = [
    "ecr.api",
    "ecr.dkr",
    "logs",
    "ssm",
    "ssmmessages",
  ]
}
