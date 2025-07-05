resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = file("~/.ssh/eks.pub")
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                  = local.name
  cluster_version               = "1.31" # later we update to 1.32
  create_node_security_group    = false
  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id
  node_security_group_id        = local.eks_node_sg_id


  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server         = {}
  }

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids



  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"] # smaller, low vCPU
  }

  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type = "ami-05ffe3c48a9991133"

      instance_types = ["t3.medium"]
      key_name       = aws_key_pair.eks.key_name

      min_size     = 1
      max_size     = 3
      desired_size = 1
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
      }
    }
  }

  tags = merge(var.common_tags,
    {
      Name = local.name
    }
  )
}
