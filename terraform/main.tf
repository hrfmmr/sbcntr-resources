module "ecs" {
  source = "./modules/ecs"

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region

  vpc_id = aws_vpc.sbcntr_vpc.id
  subnet_ids = [
    aws_subnet.sbcntr_subnet_private_container1["a"].id,
    aws_subnet.sbcntr_subnet_private_container1["c"].id,
  ]

  sg_bastion_id = aws_security_group.sbcntr_sg_bastion.id
}
