variable "vpc_id" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_mask" {
  type = number
}

variable "private_subnet_mask" {
  type = number
}

variable "project" {
  type = string
}

variable "igw_id" {
  type = string
}
