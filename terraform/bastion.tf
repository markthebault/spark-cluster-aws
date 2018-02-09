resource "aws_instance" "bastion" {
  ami           = "${lookup(var.ami_bastion, var.aws_region)}"
  instance_type = "t2.micro"
  subnet_id = "${module.vpc.public_subnets[0]}"
  security_groups = ["${aws_security_group.bastion.id}"]
  key_name = "${aws_key_pair.emr_kp.id}"

  tags {
    Name = "Bastion"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}


resource "aws_key_pair" "emr_kp" {
  key_name   = "mth-key"
  public_key = "${file("${var.key_pair_public_path}")}"
}



resource "aws_security_group" "bastion" {
  name        = "bastion-ssh-sg"
  description = "Allow ssh traffic from certain IP range to bastion on port 22"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_admin_ip_range}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
