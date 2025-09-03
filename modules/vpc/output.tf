output "vpc_id" {
  value = aws_vpc.primary.id
}

output "igw_id" {
  value = aws_internet_gateway.primary.id
}