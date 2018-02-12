data "template_file" "zeppelin_user_data" {
  template = "${file("${path.module}/spark-configuration/zeppelin-userdata.tmpl")}"

  vars {
    zeppelin_docker_image     = "${var.zeppelin_docker_image}"
    spark_proxy_docker_image  = "${var.spark_proxy_docker_image}"
    spark_master_dns          = "master.${var.private_domain}"
  }
}

resource "aws_instance" "zeppelin" {
  ami           = "${lookup(var.ami_coreos, var.aws_region)}"
  instance_type = "${var.spark_master_instance_type}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.zeppelin.id}"]
  key_name = "${aws_key_pair.emr_kp.id}"
  iam_instance_profile = "${aws_iam_instance_profile.spark_profile.id}"

  user_data = "${data.template_file.zeppelin_user_data.rendered}"

  tags {
    Name = "Zeppelin"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "zeppelin_dns_record" {
  zone_id = "${aws_route53_zone.spark_zone.zone_id}"
  name    = "zeppelin.${var.private_domain}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_instance.zeppelin.private_ip}"]
}


output "zeppelin_public_address" {
  value = "http://${aws_eip.ip_zeppelin.public_ip}:8080"
}

output "spark_ui_public_address" {
  value = "http://${aws_eip.ip_zeppelin.public_ip}:8081"
}

resource "aws_eip" "ip_zeppelin" {
  instance = "${aws_instance.zeppelin.id}"
}


resource "aws_security_group" "zeppelin" {
  name        = "zeppelin-ssh-sg"
  description = "Allow HTTP traffic on port 8080"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.public_admin_ip_range}"]
  }

  #spark proxy
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.public_admin_ip_range}"]
  }

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

resource "aws_security_group_rule" "zeppelin_to_master" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.spark_master.id}"

  security_group_id = "${aws_security_group.zeppelin.id}"
}

resource "aws_security_group_rule" "zeppelin_to_worker" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.spark_worker.id}"

  security_group_id = "${aws_security_group.zeppelin.id}"
}
