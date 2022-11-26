output "bastion_ec2_ip" {
  value = aws_instance.bastion_ec2.public_dns
}
