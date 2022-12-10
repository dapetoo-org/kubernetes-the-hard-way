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

