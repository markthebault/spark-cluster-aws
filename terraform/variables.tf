variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
  default = "default"
}

variable "public_admin_ip_range" {
  default = "0.0.0.0/0"
}

variable "environment" {
  default = "dev"
}

variable "key_pair_public_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ami_bastion" {
  type = "map"
  default = {
    "eu-west-1" = "ami-d834aba1"
    "ap-southeast-1" = "ami-68097514"
  }
}

variable "ami_coreos" {
  type = "map"
  default = {
    "eu-west-1" = "ami-a22f43db"
    "ap-southeast-1" = "ami-04c48078"
  }
}
