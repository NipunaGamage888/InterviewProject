data "aws_availability_zones" "available"{
    state ="available"
}

locals {
  azs= slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
    source   = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    project  = var.project
   
}

module "subnets" {
   source               = "./modules/subnets"
   vpc_id               = module.vpc.vpc_id
   azs                  = local.azs
   public_subnet_mask   = var.public_subnet_mask
   private_subnet_mask  = var.private_subnet_mask
   project              = var.project
   igw_id = module.vpc.igw_id
 
}
data "aws_ami" "amazon_linux"{
    most_recent=true
    owners=["amazon"]
    filter{
        name="name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

module "virtual_box"{
   source            = "./modules/ec2"
   vpc_id            = module.vpc.vpc_id
   public_subnet_ids = module.subnets.public_subnet_ids
   project           = var.project
   instance_type     = var.instance_type
   key_name          = var.key_name
   ami_id            = data.aws_ami.amazon_linux.id
   allowed_ssh_cidr  = var.allowed_ssh_cidr

}