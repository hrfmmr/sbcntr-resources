output "sg_bastion_id" {
  value = aws_security_group.sbcntr_sg_bastion.id
}

output "bastion_ec2_ip" {
  value = aws_instance.bastion_ec2.public_dns
}
