module "secrets" {
  source = "./modules/secrets"

  db_credentials = {
    username = var.db_username
    password = var.db_password
  }
}

module "network" {
  source = "./modules/network"

  aws_region = var.aws_region
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id          = module.network.vpc_id
  ssh_key_name    = var.ssh_key_name
  ssh_public_key  = var.ssh_public_key
  ssh_allowed_ips = var.bastion_ssh_allowed_ips
  ec2_ami         = var.ec2_bastion_ami
  ec2_subnet_id   = module.network.public_subnet_ids[0]

  depends_on = [
    module.network,
  ]
}

module "rds" {
  source = "./modules/rds"

  vpc_id        = module.network.vpc_id
  db_subnet_ids = module.network.private_subnet_db_ids
  db_ingress_source_security_groups = [
    module.ecs.sg_frontend_container_id,
    module.ecs.sg_backend_container_id,
    module.bastion.sg_bastion_id,
  ]
  db_name     = var.db_name
  db_username = var.db_username
  db_pass     = var.db_password

  depends_on = [
    module.network,
  ]
}

module "ecs" {
  source = "./modules/ecs"

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region

  vpc_id            = module.network.vpc_id
  sg_egress_id      = module.network.sg_egress_vpce_id
  public_subnet_ids = module.network.public_subnet_ids
  subnet_ids        = module.network.private_subnet_app_ids

  db_host = module.rds.db_host
  db_name = var.db_name

  sg_bastion_id = module.bastion.sg_bastion_id

  s3_logs_bucket     = aws_s3_bucket.sbcntr_logs.bucket
  s3_logs_bucket_arn = aws_s3_bucket.sbcntr_logs.arn

  depends_on = [
    module.secrets,
    module.network,
    module.bastion,
  ]
}
