variable "ssh_public_key" {
  type = string
}

variable "bastion_ssh_allowed_ips" {
  type = list(string)
}

variable "ec2_bastion_ami" {
  type = string
}
