# BUILDING ELASTIC KUBERNETES SERVICE (EKS) WITH TERRAFORM

This repository contains a Terraform module that can be used to deploy an EKS cluster on AWS.

```bash
# Create S# Bucket with AWS CLI
aws s3 mb s3://dapetoo-eks-terraform

# Initialize Terraform
terraform init
```

**backend.tf**

```hcl
terraform {
  backend "s3" {
    bucket = "dapetoo-eks-terraform"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}
```

VPC using AWS VPC modules and add the appropriate tags to the subnet which are neeeded for Elastic Kubernetes Service.

The following tags must be added to the subnet configuration:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
....
    tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        iac_environment                             = var.iac_environment_tag
    }
    public_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                    = "1"
        iac_environment                             = var.iac_environment_tag
    }
    private_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"           = "1"
        iac_environment                             = var.iac_environment_tag
    }
...
}

```

The tags added to the subnets is very important. The Kubernetes Cloud Controller Manager (cloud-controller-manager) and AWS Load Balancer Controller (aws-load-balancer-controller) needs to identify the cluster’s. To do that, it querries the cluster’s subnets by using the tags as a filter.

For public and private subnets that use load balancer resources: each subnet must be tagged

```
Key: kubernetes.io/cluster/cluster-name
Value: shared
```

For private subnets that use internal load balancer resources: each subnet must be tagged

```
Key: kubernetes.io/role/internal-elb
Value: 1
```

For public subnets that use internal load balancer resources: each subnet must be tagged

```
Key: kubernetes.io/role/elb
Value: 1
```

**eks.tf**

Using AWS EKS module to create the EKS cluster. 

```hcl 
module "eks_cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 18.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.22"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = var.asg_instance_types[0]
    update_launch_template_default_version = true
  }
  self_managed_node_groups = local.self_managed_node_groups

  # aws-auth configmap
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_users            = concat(local.admin_user_map_users, local.developer_user_map_users)
  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
```