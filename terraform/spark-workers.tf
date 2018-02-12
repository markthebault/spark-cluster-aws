module "asg" {
  source = "modules/autoscaling"

  name = "spark_workers"

  # Launch configuration
  lc_name = "spark-workers-lc"

  image_id              = "${lookup(var.ami_coreos, var.aws_region)}"
  instance_type         = "${var.spark_worker_instance_type}"
  user_data             = "${data.template_file.spark_worker_user_data.rendered}"
  security_groups       = ["${aws_security_group.spark_worker.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.spark_profile.id}"
  key_name              = "${aws_key_pair.emr_kp.id}"
  placement_group       = "${aws_placement_group.spark.id}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "spark-workers-asg"
  vpc_zone_identifier       = "${module.vpc.private_subnets}"
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 10
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    }
  ]
}









data "template_file" "spark_worker_user_data" {
  template = "${file("${path.module}/spark-configuration/spark-worker-userdata.tmpl")}"

  vars {
    spark_docker_image = "${var.spark_docker_image}"
    spark_master_dns = "master.${var.private_domain}"
    spark_worker_cores = "${var.spark_worker_cores}"
    spark_worker_memory = "${var.spark_worker_memory}"
  }
}


# resource "aws_instance" "spark_worker" {
#   count = 2
#   ami           = "${lookup(var.ami_coreos, var.aws_region)}"
#   instance_type = "${var.spark_worker_instance_type}"
#   subnet_id = "${module.vpc.private_subnets[0]}"
#   vpc_security_group_ids = ["${aws_security_group.spark_worker.id}"]
#   key_name = "${aws_key_pair.emr_kp.id}"
#
#   user_data = "${data.template_file.spark_worker_user_data.rendered}"
#
#   tags {
#     Name = "SparkWorker"
#     Terraform = "true"
#     Environment = "${var.environment}"
#   }
# }



resource "aws_security_group" "spark_worker" {
  name        = "spark-worker-sg"
  description = "Security group of the spark worker"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


#Security group options
resource "aws_security_group_rule" "worker_to_worker" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.spark_worker.id}"

  security_group_id = "${aws_security_group.spark_worker.id}"
}

resource "aws_security_group_rule" "worker_to_master" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.spark_master.id}"

  security_group_id = "${aws_security_group.spark_worker.id}"
}

resource "aws_security_group_rule" "worker_to_zeppelin" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.zeppelin.id}"

  security_group_id = "${aws_security_group.spark_worker.id}"
}

resource "aws_security_group_rule" "worker_to_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"

  security_group_id = "${aws_security_group.spark_worker.id}"
}
