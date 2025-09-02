locals {
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_mask  = 20
  private_subnet_mask = 20

  public_cidrs = [
    for i in range(length(local.azs)) :
    cidrsubnet("10.0.0.0/16", local.public_subnet_mask - 16, i)
  ]

  private_cidrs = [
    for i in range(length(local.azs)) :
    cidrsubnet("10.0.0.0/16", local.private_subnet_mask - 16, i + 100)
  ]
}

resource "aws_subnet" "public_subs" {
  count = length(local.azs)
  vpc_id = aws_vpc.primary.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name    = "job_assignment_public_subs-${local.azs[count.index]}"
    Project = "job_assignment"
    Tier    = "public"
  }
}

resource "aws_subnet" "private_subs" {
  count = length(local.azs)
  vpc_id = aws_vpc.primary.id
  cidr_block              = local.private_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = {  
    Name    = "job_assignment_private_subs-${local.azs[count.index]}"
    Project = "job_assignment"
    Tier    = "public"
  }
}

resource "aws_eip" "eip_nat" {
  count = length(local.azs)
  domain = "vpc"
  tags = {
    Name    = "job_assignment-eip-${local.azs[count.index]}"
    Project = "job_assignment"
  }
}

resource "aws_nat_gateway" "nategateway" {
    count = length(local.azs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id
    tags = {
        Name    = "job_assignment-nat-${local.azs[count.index]}"
        Project = "job_assignment"
    }
    depends_on = [aws_subnet.public_subs]
  
}

resource "aws_route_table" "public" {
  vpc_id =  aws_vpc.primary.id
  tags = {
    Name    = "job_assignment-public-rt"
    Project = "job_assignment"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.primary.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(local.azs)
  vpc_id = aws_vpc.primary.id
  tags = {
    Name    = "job_assignment-private-rt-${local.azs[count.index]}"
    Project = "job_assignment"
  }
}

resource "aws_route" "private_default" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}




