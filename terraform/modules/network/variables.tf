variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
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
