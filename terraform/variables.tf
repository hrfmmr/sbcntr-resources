data "aws_caller_identity" "current" {}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

# bastion
variable "ssh_key_name" {
  type = string
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
