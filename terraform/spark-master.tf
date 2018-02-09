data "template_file" "spark_master_user_data" {
  template = "${file("${path.module}/spark-configuration/spark-master-userdata.tmpl")}"

  vars {
    spark_docker_image = "${var.spark_docker_image}"
  }
}


resource "aws_instance" "spark_master" {
  ami           = "${lookup(var.ami_coreos, var.aws_region)}"
  instance_type = "${var.spark_master_instance_type}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.spark_master.id}"]
  key_name = "${aws_key_pair.emr_kp.id}"

  user_data = "${data.template_file.spark_master_user_data.rendered}"

  tags {
    Name = "SparkMaster"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}



resource "aws_security_group" "spark_master" {
  name        = "spark-master-sg"
  description = "Security group of the spark master"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
