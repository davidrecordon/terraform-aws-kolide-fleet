# terraform-aws-kolide-fleet

A Terraform module that deploys Kolide Fleet into AWS across multiple availability zones using Elastic Container Service (ECS) Fargate. It currently requires [Austin Lin's Docker container](https://hub.docker.com/r/austinylin/kolide-fleet/) where he patched Fleet to support Twirp over HTTP/1.1 instead of gRPC which means that it can use AWS' Application Load Balancer.

This is my first Terraform module so I'm sure there are suboptimal parts; feel free to submit pull requests :)


### Usage

This module assumes that you use ACM for SSL certificates and have already setup a VPC with database, elasticache, public, and private subnets. Fargate is currently only available in us-east-1.

```terraform
module "fleet-service" {
  source = "github.com/davidrecordon/terraform-aws-kolide-fleet"

  acm_certificate_arn = "${acm_certificate_arn}"

  auth_jwt_key = "s3cr3t"

  aws_region = "us-east-1"
  aws_zones  = ["us-east-1a", "us-east-1b"]

  db_password = "pa$$w0rd"
  db_subnet_group_name = "${aws_subnet.db_subnet_group_name.name}"

  elasticache_subnet_group_name = "${aws_subnet.elasticache_subnet_group_name.name}"

  private_subnet_ids = ["${aws_subnet.private_subnet.*.id}"]
  public_subnet_ids  = ["${aws_subnet.public_subnet.*.id}"]

  vpc_id = "${aws_vpc.id}"
}
```

You'll need to manually run a server task to run `/usr/bin/fleet prepare db` once the infrastructure is all spun up.


### Variables

- `acm_certificate_arn` - ARN of the ACM certificate which can be used for the load balancer.
- `auth_jwt_key` - Passed to the Fleet server.
- `aws_region` - Region you're deploying into.
- `aws_zones` - List of availability zones Fleet should be deployed across.
- `db_password`
- `db_subnet_group_name` - This could be the same as your private subnet, but I split them apart.
- `docker_image` - Where to fetch the Docker image for the Fleet server ECS tasks.
- `elasticache_subnet_group_name` - This could be the same as your private subnet, but I split them apart.
- `private_subnet_ids` - IDs for the private subnets Fleet should be deployed across. We assume one per availability zone.
- `public_subnet_ids` - IDs for the public subnets the load balancer should be deployed across. We assume one per availability zone.
- `vpc_id` - ID of the VPC which Fleet and its required infrastructure will be deployed within.


### Outputs

- `fleet_alb_dns_name` - DNS name of the load balancer. I use Terraform to create a nice CNAME pointed at this.
