module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access_cidrs = ["10.0.0.0/8"]
  cluster_endpoint_public_access_cidrs = ["1.1.1.1/32"] ######Your Public IP

  tags = {
    Environment = "dev"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp3"
    disk_size = 50
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3a.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      asg_max_size                  = 5
      asg_min_size                  = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
