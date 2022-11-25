resource "aws_vpc" "sbcntr_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "sbcntrVpc"
  }
}

# Public subnet
resource "aws_subnet" "sbcntr_subnet_public_ingress1" {
  for_each = {
    "a" = "10.0.0.0/24"
    "c" = "10.0.1.0/24"
  }
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  cidr_block              = each.value
  availability_zone       = "ap-northeast-1${each.key}"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1${each.key}"
    Type = "Public"
  }
}

resource "aws_route_table" "sbcntr_route_ingress" {
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Name = "sbcntr-route-ingress"
  }
}

resource "aws_route" "sbcntr_route_ingress_default" {
  route_table_id         = aws_route_table.sbcntr_route_ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sbcntr_igw.id
}

resource "aws_route_table_association" "sbcntr_route_ingress_association1" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }
  route_table_id = aws_route_table.sbcntr_route_ingress.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_ingress1[each.key].id
}

resource "aws_internet_gateway" "sbcntr_igw" {
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-igw"
  }
}

# Private subnet(Container)
resource "aws_subnet" "sbcntr_subnet_private_container1" {
  for_each = {
    "a" = "10.0.8.0/24"
    "c" = "10.0.9.0/24"
  }
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  cidr_block              = each.value
  availability_zone       = "ap-northeast-1${each.key}"
  map_public_ip_on_launch = true
  tags = {
    Name = "sbcntr-subnet-private-container-1${each.key}"
    Type = "Isolated"
  }
}

resource "aws_route_table" "sbcntr_route_app" {
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Key  = "Name"
    Name = "sbcntr-route-app"
  }
}

resource "aws_route_table_association" "sbcntr_route_app_association1" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }
  route_table_id = aws_route_table.sbcntr_route_app.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_container1[each.key].id
}

# Private subnet(DB)
resource "aws_subnet" "sbcntr_subnet_private_db1" {
  for_each = {
    "a" = "10.0.16.0/24"
    "c" = "10.0.17.0/24"
  }
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  cidr_block              = each.value
  availability_zone       = "ap-northeast-1${each.key}"
  map_public_ip_on_launch = false
  tags = {
    Name = "sbcntr-subnet-private-db-1${each.key}"
    Type = "Isolated"
  }
}

resource "aws_route_table" "sbcntr_route_db" {
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Name = "sbcntr-route-db"
  }
}

resource "aws_route_table_association" "sbcntr_route_db_association1" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }
  route_table_id = aws_route_table.sbcntr_route_db.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_db1[each.key].id
}

# TODO:
# resource "aws_ec2_transit_gateway_vpc_attachment" "sbcntr_vpcgw_attachment" {
# vpc_id             = aws_internet_gateway.sbcntr_igw.id
# subnet_ids         = [aws_subnet.example.id]
# transit_gateway_id = aws_ec2_transit_gateway.example.id
# }

# Security groups

## インターネット公開のセキュリティグループ
resource "aws_security_group" "sbcntr_sg_ingress" {
  description = "Security group for ingress"
  name        = "ingress"
  tags = {
    Name = "sbcntr-sg-ingress"
  }
  vpc_id = aws_vpc.sbcntr_vpc.id
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


## バックエンドコンテナアプリ用セキュリティグループ
resource "aws_security_group" "sbcntr_sg_container" {
  description = "Security Group of backend app"
  name        = "container"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Name = "sbcntr-sg-container"
  }
}

## フロントエンドコンテナアプリ用セキュリティグループ
resource "aws_security_group" "sbcntr_sg_front_container" {
  description = "Security Group of front container app"
  name        = "front-container"
  vpc_id      = aws_vpc.sbcntr_vpc.id
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

## 内部用ロードバランサ用のセキュリティグループ
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
  vpc_id = aws_vpc.sbcntr_vpc.id
}

## DB用セキュリティグループ
resource "aws_security_group" "sbcntr_sg_db" {
  description = "Security Group of database"
  name        = "database"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
  tags = {
    Name = "sbcntr-sg-db"
  }
  vpc_id = aws_vpc.sbcntr_vpc.id
}

# ルール紐付け

## Internet LB -> Front Container
resource "aws_security_group_rule" "sbcntr_sg_front_container_froms_sg_ingress" {
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

## Bastion -> Internal LB
resource "aws_security_group_rule" "sbcntr_sg_internal_from_bastion" {
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  type                     = "ingress"
  from_port                = 10080
  to_port                  = 10080
  source_security_group_id = aws_security_group.sbcntr_sg_bastion.id
  protocol                 = "tcp"
  description              = "HTTP for bastion"
}
resource "aws_security_group_rule" "sbcntr_sg_internal_from_bastion_debug" {
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  type                     = "ingress"
  from_port                = 20080
  to_port                  = 20080
  source_security_group_id = aws_security_group.sbcntr_sg_bastion.id
  protocol                 = "tcp"
  description              = "Debug HTTP for bastion"
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

## Back container -> DB
resource "aws_security_group_rule" "sbcntr_sg_db_from_sg_container_tcp" {
  security_group_id        = aws_security_group.sbcntr_sg_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.sbcntr_sg_container.id
  description              = "MySQL protocol from backend App"
}

## Front container -> DB
resource "aws_security_group_rule" "sbcntr_sg_db_from_sg_front_container_tcp" {
  security_group_id        = aws_security_group.sbcntr_sg_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.sbcntr_sg_front_container.id
  description              = "MySQL protocol from frontend App"
}
