resource "aws_vpc" "sbcntr_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "sbcntr-vpc"
  }
}

# Public subnet
resource "aws_subnet" "sbcntr_subnet_public_ingress1" {
  for_each = zipmap(
    local.availability_zones,
    local.public_subnet_cidrs
  )
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
  for_each       = toset(local.availability_zones)
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
# resource "aws_eip" "sbcntr_nat_eip" {
# for_each = toset(local.availability_zones)

# vpc = true

# tags = {
# Name = "sbcntr-nat-${each.key}"
# }
# }

# resource "aws_nat_gateway" "sbcntr_nat" {
# for_each = toset(local.availability_zones)

# subnet_id     = aws_subnet.sbcntr_subnet_public_ingress1[each.key].id
# allocation_id = aws_eip.sbcntr_nat_eip[each.key].id

# tags = {
# Name = "sbcntr-natgw-${each.key}"
# }
# }


# Private subnet(Container)
resource "aws_subnet" "sbcntr_subnet_private_container1" {
  for_each = zipmap(
    local.availability_zones,
    local.private_subnet_container_cidrs
  )

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
  for_each = toset(local.availability_zones)

  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-route-app-${each.key}"
  }
}

# resource "aws_route" "sbcntr_route_app_natgw" {
# for_each = toset(local.availability_zones)

# route_table_id         = aws_route_table.sbcntr_route_app[each.key].id
# destination_cidr_block = "0.0.0.0/0"
# nat_gateway_id         = aws_nat_gateway.sbcntr_nat[each.key].id
# }

resource "aws_route_table_association" "sbcntr_route_app_association1" {
  for_each = toset(local.availability_zones)

  route_table_id = aws_route_table.sbcntr_route_app[each.key].id
  subnet_id      = aws_subnet.sbcntr_subnet_private_container1[each.key].id
}

# Private subnet(VPC endpoint)
resource "aws_subnet" "sbcntr_subnet_private_egress1" {
  for_each = zipmap(
    local.availability_zones,
    local.private_subnet_vpce_cidrs
  )

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
  for_each = zipmap(
    local.availability_zones,
    local.private_subnet_db_cidrs
  )

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
  for_each = toset(local.availability_zones)

  route_table_id = aws_route_table.sbcntr_route_db.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_db1[each.key].id
}

