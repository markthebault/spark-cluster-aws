
provider "aws" {
  version = "~> 1.0.0"
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}
