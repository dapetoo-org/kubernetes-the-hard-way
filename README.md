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

Initialize terraform with the modules and create the EKS cluster.

```bash
terraform init
terraform plan
terraform apply
``` 

```
#Update Kubeconfig
aws eks --region us-east-2 update-kubeconfig --name tooling-app-eks

## DEPLOY APPLICATIONS WITH HELM

A Helm chart is a definition of the resources that are required to run an application in Kubernetes. Instead of having to think about all of the various deployments/services/volumes/configmaps/ etc that make up your application, you can use a command like

```
helm install stable/mysql
```

and Helm will make sure all the required resources are installed. In addition you will be able to tweak helm configuration by setting a single variable to a particular value and more or less resources will be deployed. For example, enabling slave for MySQL so that it can have read only replicas.

```
#Install HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm version

#Deploy Jenkins
#Add repository
helm repo add jenkinsci https://charts.jenkins.io
helm repo update

#Install Chart
helm install my-jenkins jenkinsci/jenkins --version 4.2.17
helm ls
kubectl exec --namespace default -it svc/my-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

kubectl --namespace default port-forward svc/my-jenkins 8080:8080

# Deploy Artifactory
helm repo add jfrog https://charts.jfrog.io
helm repo update
helm install my-artifactory jfrog/artifactory --version 107.47.11

# Deploy Prometheus
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/kube-prometheus


Watch the Prometheus Operator Deployment status using the command:

    kubectl get deploy -w --namespace default -l app.kubernetes.io/name=kube-prometheus-operator,app.kubernetes.io/instance=my-release

Watch the Prometheus StatefulSet status using the command:

    kubectl get sts -w --namespace default -l app.kubernetes.io/name=kube-prometheus-prometheus,app.kubernetes.io/instance=my-release

Prometheus can be accessed via port "9090" on the following DNS name from within your cluster:

    my-release-kube-prometheus-prometheus.default.svc.cluster.local

To access Prometheus from outside the cluster execute the following commands:

    echo "Prometheus URL: http://127.0.0.1:9090/"
    kubectl port-forward --namespace default svc/my-release-kube-prometheus-prometheus 9090:9090

Watch the Alertmanager StatefulSet status using the command:

    kubectl get sts -w --namespace default -l app.kubernetes.io/name=kube-prometheus-alertmanager,app.kubernetes.io/instance=my-release

Alertmanager can be accessed via port "9093" on the following DNS name from within your cluster:

    my-release-kube-prometheus-alertmanager.default.svc.cluster.local

To access Alertmanager from outside the cluster execute the following commands:

    echo "Alertmanager URL: http://127.0.0.1:9093/"
    kubectl port-forward --namespace default svc/my-release-kube-prometheus-alertmanager 9093:9093

# Deploy Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install my-release-grafana grafana/grafana

1. Get your 'admin' user password by running:

   kubectl get secret --namespace default my-release-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   my-release-grafana.default.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
     export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=my-release-grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace default port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin



# Deploy ECK using Helm
helm repo add elastic https://helm.elastic.co
helm repo update

# Deploy Hashicorp Vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault
