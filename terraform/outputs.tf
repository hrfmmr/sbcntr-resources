output "example_ec2_ip" {
  value = aws_instance.bastion_ec2.public_dns
}

output "internal_alb_ip" {
  value = aws_lb.internal.dns_name
}
