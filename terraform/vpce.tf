# Security Group
resource "aws_security_group" "sbcntr_sg_egress" {
  name        = "egress"
  description = "Security group of VPC Endpoint"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "sbcntr-sg-vpce"
  }
}

# VPC Endpoint

## Interface
resource "aws_vpc_endpoint" "sbcntr_vpce" {
  for_each = toset(var.vpc_interface_endpoints)

  vpc_id              = aws_vpc.sbcntr_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.sbcntr_subnet_private_egress1)[*].id
  security_group_ids  = [aws_security_group.sbcntr_sg_egress.id]
  private_dns_enabled = true
}

## Gateway
resource "aws_vpc_endpoint" "sbcntr_vpce_s3" {
  vpc_id            = aws_vpc.sbcntr_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "sbcntr_route_private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.sbcntr_vpce_s3.id
  route_table_id  = aws_route_table.sbcntr_route_app.id
}
