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
  subnet_id = "${module.vpc.private_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.zeppelin.id}"]
  key_name = "${aws_key_pair.emr_kp.id}"
  iam_instance_profile = "${aws_iam_instance_profile.spark_profile.id}"
  placement_group = "${aws_placement_group.spark.id}"

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


resource "aws_security_group" "zeppelin" {
  name        = "zeppelin-ssh-sg"
  description = "Allow HTTP traffic on port 8080"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = ["${aws_security_group.zeppelin_elb.id}"]
  }

  #spark proxy
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups = ["${aws_security_group.zeppelin_elb.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.bastion.id}"]
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
