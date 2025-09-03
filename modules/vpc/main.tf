resource "aws_vpc" "primary" {
  cidr_block = var.vpc_cidr
  tags = {
    name= "job_assignment-vpc"
    project= var.project
  }
}

resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
  tags = {
    name= "job_assignment-vpc"
    project= var.project
  }
}