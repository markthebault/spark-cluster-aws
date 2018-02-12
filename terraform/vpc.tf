module "vpc" {
  source = "modules/vpc"

  name = "spark-cluster"
  cidr = "10.232.0.0/22"

  azs             = ["${var.aws_region}a"]
  private_subnets = ["10.232.1.0/26"]
  public_subnets  = ["10.232.2.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_zone" "spark_zone" {
  name   = "${var.private_domain}"
  vpc_id = "${module.vpc.vpc_id}"
}
