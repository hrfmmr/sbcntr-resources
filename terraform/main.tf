module "rds" {
  source = "./modules/rds"

  vpc_id        = aws_vpc.sbcntr_vpc.id
  db_subnet_ids = values(aws_subnet.sbcntr_subnet_private_db1)[*].id
  db_ingress_source_security_groups = [
    module.ecs.sg_frontend_container_id,
    module.ecs.sg_backend_container_id,
    aws_security_group.sbcntr_sg_bastion.id,
  ]
  db_name     = var.db_name
  db_username = var.db_username
  db_pass     = var.db_pass
}

module "ecs" {
  source = "./modules/ecs"

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region

  vpc_id            = aws_vpc.sbcntr_vpc.id
  sg_egress_id      = aws_security_group.sbcntr_sg_egress.id
  public_subnet_ids = values(aws_subnet.sbcntr_subnet_public_ingress1)[*].id
  subnet_ids        = values(aws_subnet.sbcntr_subnet_private_container1)[*].id

  sg_bastion_id = aws_security_group.sbcntr_sg_bastion.id
}
