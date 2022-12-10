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


