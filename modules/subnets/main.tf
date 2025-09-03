locals {
  public_cidrs  = [for i in range(length(var.azs)) : cidrsubnet("10.0.0.0/16", var.public_subnet_mask - 16, i)]
  private_cidrs = [for i in range(length(var.azs)) : cidrsubnet("10.0.0.0/16", var.private_subnet_mask - 16, i + 100)]
}

resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = var.vpc_id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}_public_subs-${var.azs[count.index]}"
    Project = var.project
    Tier    = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.azs)
  vpc_id = var.vpc_id
  cidr_block              = local.private_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {  
    Name    = "${var.project}_private_subs-${var.azs[count.index]}"
    Project = var.project
    Tier    = "public"
  }
}

resource "aws_eip" "nat" {
  count = length(var.azs)
  domain = "vpc"
  tags = {
    Name    = "${var.project}-eip-${var.azs[count.index]}"
    Project = var.project
  }
}

resource "aws_nat_gateway" "nat" {
    count = length(var.azs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id
    tags = {
        Name    = "${var.project}-nat-${var.azs[count.index]}"
        Project = var.project
    }
    depends_on = [aws_subnet.public]
  
}

resource "aws_route_table" "public" {
  vpc_id =  var.vpc_id
  tags = {
    Name    = "${var.project}-public-rt"
    Project = var.project
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.azs)
  vpc_id = var.vpc_id
  tags = {
    Name    = "${var.project}-private-rt-${var.azs[count.index]}"
    Project = var.project
  }
}

resource "aws_route" "private_default" {
  count                  = length(var.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}




