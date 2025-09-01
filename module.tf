data "aws_availability_zones" "available"{
    state ="available"
}

locals {
  azs= slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cdr="10.0.0.0/16"
    project="job_assignment"
}

module "subnets" {
  source= "./modules/subnets"
  vpc_id= module.vpc.vpc_id
  azs= local.azs
  public_subnet_masks= 24
  private_subnet_masks= 24
  project= "job_assignment"
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
    source = "./modules/ec2"
    vpc_id=module.vpc.vpc_id
    public_subnet_ids = module.subnets.public_subnet_ids
    project = var.project
    instance_type = var.instance_type
    key_name = var.key_name
    ami_id = data.aws_ami.amazon_linux.id
    allowed_ssh_cidr  = var.allowed_ssh_cidr

}