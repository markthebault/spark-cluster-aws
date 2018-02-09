data "template_file" "spark_worker_user_data" {
  template = "${file("${path.module}/spark-configuration/spark-worker-userdata.tmpl")}"

  vars {
    spark_docker_image = "${var.spark_docker_image}"
    spark_master_dns = "${aws_instance.spark_master.private_dns}"
    spark_worker_cores = "${var.spark_worker_cores}"
    spark_worker_memory = "${var.spark_worker_memory}"
  }
}


resource "aws_instance" "spark_worker" {
  count = 2
  ami           = "${lookup(var.ami_coreos, var.aws_region)}"
  instance_type = "${var.spark_worker_instance_type}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  security_groups = ["${aws_security_group.spark_worker.id}"]
  key_name = "${aws_key_pair.emr_kp.id}"

  user_data = "${data.template_file.spark_worker_user_data.rendered}"

  tags {
    Name = "SparkWorker"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}



resource "aws_security_group" "spark_worker" {
  name        = "spark-worker-sg"
  description = "Security group of the spark worker"
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
