# Spark cluster on AWS
In this repository you will find a basic terraform configuration to create a spark standalone cluster based on docker images.
In addition of the spark cluster, there is a Zeppelin instance to allow developers to run notebooks.
There is also a bastion host with is used to ssh into the VMs.

All spark related instances are base on CoreOS stable images running containers on with the docker Host mode.

## Architecture
The spark cluster is on a private subnet. There is different security groups between the master and the workers.
Bastion and the zeppelin instance are running in the public subnet.

Make sure you change the default value for the variable `public_admin_ip_range` and set it up to you ip address

The spark workers are created by an auto scaling group. Adjust the trigger to your needs.

![Cluster schemas](https://github.com/markthebault/spark-cluster-aws/raw/master/spark-cluster.png)

There is a private host zone created to add dns support for the spark master and the zeppelin server. This is a private zone, it will not be reachable from internet.

Since the Spark cluster is in a private subnet, the Spark ui is not directly reachable. Adding a openvpn server to this repo would be too heavy, so I used a very cool proxy based on [this repository](https://github.com/aseigneurin/spark-ui-proxy). This proxy is running on the zeppelin instance.

## To know before running
This is for development purpose, there is no high availability for the spark master. If feel free to submit a pool request with the [support of zookeeper for the master HA.](https://spark.apache.org/docs/latest/spark-standalone.html#high-availability)

Before using this repository make sure you update the instance profile of the spark cluster (in terraform/spark-master resource spark_cluster_policy) otherwise spark will have access to all your S3 buckets.

## Things to add
This is the list of the missing feature that would be great to have
- Support of users in zeppelin with passwords
- customisable spark-configuration
