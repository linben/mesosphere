provider "aws" {
  region = "us-west-2"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "blin-demo"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.3.0"

  providers = {
    aws = aws
  }

  cluster_name        = local.cluster_name
  ssh_public_key_file = "~/.ssh/training_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 3
  num_public_agents  = 1

  dcos_instance_os        = "centos_7.5"
  bootstrap_instance_type = "m4.xlarge"

  dcos_variant              = "ee"
  dcos_version              = "2.1.0"
  dcos_license_key_contents = "${file("/Users/blin/Documents/projects/license.txt")}"

  tags = {
    owner = "ben.lin"
    expiration = "3h"
  }

}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = module.dcos.masters-loadbalancer
}

#provider "dcos" {}
#
#resource "dcos_job" "testjob1" {
#  jobid = "testjob1"
#
#  run {
#    disk = 50
#    cpus = 0.1
#    mem  = 128
#    cmd  = "echo testjob1"
#  }
#
#  description = "testjob1 description"
