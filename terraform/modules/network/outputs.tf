output "vpc_id" {
  value = aws_vpc.sbcntr_vpc.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.sbcntr_subnet_public_ingress1)[*].id
}

output "private_subnet_app_ids" {
  value = values(aws_subnet.sbcntr_subnet_private_container1)[*].id
}

output "private_subnet_db_ids" {
  value = values(aws_subnet.sbcntr_subnet_private_db1)[*].id
}

output "sg_egress_vpce_id" {
  value = aws_security_group.sbcntr_sg_egress.id
}
