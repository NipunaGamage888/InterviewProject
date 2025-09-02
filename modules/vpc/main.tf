resource "aws_vpc" "primary" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name= "job_assignment-vpc"
    project= "job_assignment"
  }
}

resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
  tags = {
    name= "job_assignment-vpc"
    project= "job_assignment"
  }
}