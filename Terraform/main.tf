provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-demo-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Enable public IP assignment for subnets
  map_public_ip_on_launch = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    demo_nodes = {
      instance_types = ["t2.medium"]
      desired_size   = 1
      max_size       = 1
      min_size       = 1

      disk_size = 10 # Small disk size (10GiB)
    }
  }

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

}
