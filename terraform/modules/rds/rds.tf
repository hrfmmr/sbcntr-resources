resource "aws_db_subnet_group" "sbcntr_rds" {
  name        = "sbcntr-rds-subnet-group"
  description = "RDS subnet group for sbcntr"
  subnet_ids  = var.db_subnet_ids
}

resource "aws_db_parameter_group" "sbcntr_db_parameter_group" {
  name   = "sbcntr-mysql-param"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "sbcntr_db" {
  identifier                = "sbcntr-db-mysql"
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t2.micro"
  db_name                   = local.db.name
  username                  = local.db.username
  password                  = local.db.pass
  parameter_group_name      = aws_db_parameter_group.sbcntr_db_parameter_group.name
  db_subnet_group_name      = aws_db_subnet_group.sbcntr_rds.id
  vpc_security_group_ids    = [aws_security_group.sbcntr_sg_db.id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}
