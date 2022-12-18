output "bastion_ec2_ip" {
  value = module.bastion.bastion_ec2_ip
}

output "rds_db_endpoint" {
  value = module.rds.db_endpoint
}
