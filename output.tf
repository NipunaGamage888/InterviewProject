output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.subnets.nat_gateway_ids
}

output "web_instance_public_ip" {
  value = module.virtual_box.instance_public_ip
}
