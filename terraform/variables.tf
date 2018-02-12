variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
  default = "default"
}

variable "private_domain" {
  default = "cluster.spark"
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

variable "spark_master_instance_type" {
  default = "m4.large"
}

######################### CONFI workers
variable "spark_worker_instance_type" {
  default = "m4.large"
}
variable "desired_number_of_spark_workers" {
  default = "3"
}

variable "spark_worker_memory" {
  default = "6gb"
}

variable "spark_worker_cores" {
  default = "2"
}
###############################

variable "spark_docker_image" {
  default = "gettyimages/spark:2.2.1-hadoop-2.7"
}

variable "zeppelin_docker_image" {
  default = "markthebault/zeppelin:0.7.3-spark2.2.1"
}

variable "spark_proxy_docker_image" {
  default = "markthebault/spark-ui-proxy"
}
