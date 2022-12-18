resource "aws_security_group" "sbcntr_sg_db" {
  name        = "database"
  description = "Security Group of database"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = var.db_ingress_source_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sbcntr-sg-db"
  }
}
