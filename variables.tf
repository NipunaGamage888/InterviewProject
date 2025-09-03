variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 3
}

variable "public_subnet_mask" {
  type    = number
  default = 24
}

variable "private_subnet_mask" {
  type    = number
  default = 24
}

variable "project" {
  type    = string
  default = "job_assignment"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
