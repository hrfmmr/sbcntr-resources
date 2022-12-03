module "ecs" {
  source = "./modules/ecs"

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region

  vpc_id       = aws_vpc.sbcntr_vpc.id
  sg_egress_id = aws_security_group.sbcntr_sg_egress.id
  subnet_ids   = values(aws_subnet.sbcntr_subnet_private_container1)[*].id

  sg_bastion_id = aws_security_group.sbcntr_sg_bastion.id
}
