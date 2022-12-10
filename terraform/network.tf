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

# NAT Gateway
resource "aws_eip" "sbcntr_nat_eip" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }

  vpc = true

  tags = {
    Name = "sbcntr-nat-${each.key}"
  }
}

resource "aws_nat_gateway" "sbcntr_nat" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }

  subnet_id     = aws_subnet.sbcntr_subnet_public_ingress1[each.key].id
  allocation_id = aws_eip.sbcntr_nat_eip[each.key].id

  tags = {
    Name = "sbcntr-natgw-${each.key}"
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
  for_each = {
    "a" = "1"
    "c" = "2"
  }
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-route-app-${each.key}"
  }
}

resource "aws_route" "sbcntr_route_app_natgw" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }

  route_table_id         = aws_route_table.sbcntr_route_app[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.sbcntr_nat[each.key].id
}

resource "aws_route_table_association" "sbcntr_route_app_association1" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }

  route_table_id = aws_route_table.sbcntr_route_app[each.key].id
  subnet_id      = aws_subnet.sbcntr_subnet_private_container1[each.key].id
}

# Private subnet(VPC endpoint)
resource "aws_subnet" "sbcntr_subnet_private_egress1" {
  for_each = {
    "a" = "10.0.248.0/24"
    "c" = "10.0.249.0/24"
  }
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  cidr_block              = each.value
  availability_zone       = "ap-northeast-1${each.key}"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1${each.key}"
    Type = "Isolated"
  }
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

## DB用セキュリティグループ
resource "aws_security_group" "sbcntr_sg_db" {
  name        = "database"
  description = "Security Group of database"
  vpc_id      = aws_vpc.sbcntr_vpc.id

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
}

# ルール紐付け

## Back container -> DB
# resource "aws_security_group_rule" "sbcntr_sg_db_from_sg_container_tcp" {
# security_group_id        = aws_security_group.sbcntr_sg_db.id
# type                     = "ingress"
# protocol                 = "tcp"
# from_port                = 3306
# to_port                  = 3306
# source_security_group_id = aws_security_group.sbcntr_sg_container.id
# description              = "MySQL protocol from backend App"
# }

## Front container -> DB
# resource "aws_security_group_rule" "sbcntr_sg_db_from_sg_front_container_tcp" {
# security_group_id        = aws_security_group.sbcntr_sg_db.id
# type                     = "ingress"
# protocol                 = "tcp"
# from_port                = 3306
# to_port                  = 3306
# source_security_group_id = aws_security_group.sbcntr_sg_front_container.id
# description              = "MySQL protocol from frontend App"
# }
