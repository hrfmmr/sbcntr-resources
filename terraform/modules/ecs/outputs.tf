output "sg_frontend_container_id" {
  value = aws_security_group.sbcntr_sg_front_container.id
}

output "sg_backend_container_id" {
  value = aws_security_group.sbcntr_sg_container.id
}

output "internal_alb_ip" {
  value = aws_lb.internal.dns_name
}
