variable "vpc_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_allowed_ips" {
  type = list(string)
}

variable "ec2_ami" {
  type = string
}

variable "ec2_subnet_id" {
  type = string
}
