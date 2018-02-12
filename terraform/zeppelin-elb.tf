resource "aws_elb" "zeppelin" {
  name               = "zeppelin-elb"
  security_groups    = ["${aws_security_group.zeppelin_elb.id}"]
  subnets            = ["${module.vpc.public_subnets[0]}"]
  internal        = false

  #Zeppelin UI
  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  #Spark proxy
  listener {
    instance_port     = 8081
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 10
  }

  instances                   = ["${aws_instance.zeppelin.id}"]
  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "zeppelin-elb"
    Environment = "${var.environment}"
    terraform = "true"
  }
}


resource "aws_security_group" "zeppelin_elb" {
  name        = "zeppelin-elb-sg"
  description = "Allow HTTP from the web (admin ip range)"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_admin_ip_range}"]
  }

  #spark proxy
  ingress {
    from_port   = 8080
    to_port     = 8080
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


output "zeppelin_public_address" {
  value = "http://${aws_elb.zeppelin.dns_name}"
}

output "spark_ui_public_address" {
  value = "http://${aws_elb.zeppelin.dns_name}:8080"
}
