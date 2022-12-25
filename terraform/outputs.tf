output "bastion_ec2_ip" {
  value = module.bastion.bastion_ec2_ip
}

output "rds_db_host" {
  value = module.rds.db_host
}
