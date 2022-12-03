## Internet-facing LB
resource "aws_security_group" "sbcntr_sg_ingress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sbcntr-sg-ingress"
  }
}

resource "aws_security_group_rule" "sbcntr_sg_ingress_out" {
  security_group_id = aws_security_group.sbcntr_sg_ingress.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic by default"
}

resource "aws_security_group_rule" "sbcntr_sg_ingress_in_http_ipv4" {
  security_group_id = aws_security_group.sbcntr_sg_ingress.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  ipv6_cidr_blocks  = ["::/0"]
  description       = "from 0.0.0.0/0:80"
}

resource "aws_security_group_rule" "sbcntr_sg_ingress_in_http_ipv6" {
  security_group_id = aws_security_group.sbcntr_sg_ingress.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "from ::/0:80"
}


## Backend app
resource "aws_security_group" "sbcntr_sg_container" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = var.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "sbcntr-sg-container"
  }
}

## Frontend app
resource "aws_security_group" "sbcntr_sg_front_container" {
  description = "Security Group of front container app"
  name        = "front-container"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sbcntr-sg-front-container"
  }
}

resource "aws_security_group_rule" "sbcntr_sg_front_container_out" {
  security_group_id = aws_security_group.sbcntr_sg_front_container.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic by default"
}

## Internal LB
resource "aws_security_group" "sbcntr_sg_internal" {
  description = "Security group for internal load balancer"
  name        = "internal"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
  tags = {
    Name = "sbcntr-sg-internal"
  }
  vpc_id = var.vpc_id
}


## Internet LB -> Front Container
resource "aws_security_group_rule" "sbcntr_sg_front_container_from_sg_ingress" {
  security_group_id        = aws_security_group.sbcntr_sg_front_container.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.sbcntr_sg_ingress.id
  description              = "HTTP for Ingress"
}

## Front Container -> Internal LB
resource "aws_security_group_rule" "sbcntr_sg_internal_from_sg_front_container" {
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.sbcntr_sg_front_container.id
  description              = "HTTP for front container"
}

## Internal LB -> Back Container
resource "aws_security_group_rule" "sbcntr_sg_container_from_sg_internal" {
  security_group_id        = aws_security_group.sbcntr_sg_container.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.sbcntr_sg_internal.id
  description              = "HTTP for internal lb"
}

## Bastion -> Internal LB
resource "aws_security_group_rule" "sbcntr_sg_internal_from_bastion" {
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  type                     = "ingress"
  from_port                = 10080
  to_port                  = 10080
  source_security_group_id = var.sg_bastion_id
  protocol                 = "tcp"
  description              = "HTTP for bastion"
}

resource "aws_security_group_rule" "sbcntr_sg_internal_from_bastion_debug" {
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  type                     = "ingress"
  from_port                = 20080
  to_port                  = 20080
  source_security_group_id = var.sg_bastion_id
  protocol                 = "tcp"
  description              = "Debug HTTP for bastion"
}

## Back Container -> VPC Endpoint
resource "aws_security_group_rule" "sbcntr_sg_egress_from_sg_container" {
  security_group_id        = var.sg_egress_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.sbcntr_sg_container.id
  description              = "HTTPS for Container App"
}

## Front Container -> VPC Endpoint
resource "aws_security_group_rule" "sbcntr_sg_egress_from_sg_front_container" {
  security_group_id        = var.sg_egress_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.sbcntr_sg_front_container.id
  description              = "HTTPS for Front Container App"
}
