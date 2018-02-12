# Spark cluster on AWS
In this repository you will find a basic terraform configuration to create a spark standalone cluster based on docker images.
In addition of the spark cluster, there is a Zeppelin instance to allow developers to run notebooks.
There is also a bastion host with is used to ssh into the VMs.

All spark related instances are base on CoreOS stable images running containers on with the docker Host mode.

## Architecture
The spark cluster and the zeppelin server are on a private subnet. There is different security groups between the master and the workers.
Bastion is running in the public subnet. An Classical load balancer is running in a public subnet to balance the zeppelin traffic.

Make sure you change the default value for the variable `public_admin_ip_range` and set it up to you ip address

The spark workers are created by an auto scaling group. Adjust the trigger to your needs.

![Cluster schemas](https://github.com/markthebault/spark-cluster-aws/raw/master/spark-cluster.png)

There is a private host zone created to add dns support for the spark master and the zeppelin server. This is a private zone, it will not be reachable from internet.

Since the Spark cluster is in a private subnet, the Spark ui is not directly reachable. Adding a openvpn server to this repo would be too heavy, so I used a very cool proxy based on [this repository](https://github.com/aseigneurin/spark-ui-proxy). This proxy is running on the zeppelin instance. And serverd via the Load balances

## To know before running
This is for development purpose, there is no high availability for the spark master. If feel free to submit a pool request with the [support of zookeeper for the master HA.](https://spark.apache.org/docs/latest/spark-standalone.html#high-availability)

Before using this repository make sure you **update the instance profile of the spark cluster** (in terraform/spark-master resource spark_cluster_policy) otherwise spark will have access to all your S3 buckets.

## How to run
In the ./terraform dirrectory you can create a terraform.tfvars if you want to customize the different variable of this project.
To create the ressources:
```
$ make
```

Terraform will output the zeppelin URL and the Spark UI URL as following :
- zeppelin_public_address = http://.....
- spark_ui_public_address = http://.....:8080

## Best practice
In the current state, to facilitate the testing, terraform local state is used. I will advice you to use terraform remote states with AWS S3 as backend and DynamoDB as locking. In order to use that, create a new `a-funny-file-name.tf` file in the `./terraform/` directory with the following content:

```
# The s3 bucket and the DynamoDB table must be created before using remote states
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "spark-cluster/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
```

## Things to add
This is the list of the missing feature that would be great to have
- Support of users in zeppelin with passwords
- customisable spark-configuration
