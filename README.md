# Kubernetes 

## Kubernetes Architecture Reference

This repository contains the Kubernetes Architecture Reference, a collection of diagrams and documentation that describe the architecture of Kubernetes.

Kubernetes components

Kubernetes is a system for managing containerized applications across multiple hosts. It provides basic mechanisms for deployment, maintenance, and scaling of applications.

The Kubernetes system consists of a set of components that interact through the Kubernetes API. The Kubernetes API is exposed through the kubectl command-line interface and the Kubernetes dashboard.

The Kubernetes system components are: 

## Project Requirements

- 3 AWS EC2 instances
- Docker engine installed on the EC2 instance
- Kubernetes installed on the EC2 instance
- Kubectl installed on the EC2 instance
- cfssl and cfssljson installed on the EC2 instance
- awscli 

### Architecture Requirements
- One Kubernetes Master
- Two Kubernetes Worker Nodes
- Configured SSL/TLS certificates for Kubernetes components to communicate securely
- Configured Node Network
- Configured Pod Network

### Installing Software Requirements on Host machine
- AWS CLI and authenticate with AWS credentials

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws configure
```

- Install cfssl and cfssljson

CFSSL is CloudFlare’s open source PKI/TLS tool for signing, verifying, and bundling TLS certificates on Linux, macOS and Windows machines. By picking the right chain of certificates, CFSSL solves the balancing act between performance, security, and compatibility.

CFSSL consists of:
A set of packages useful for building custom TLS PKI tools
The cfssl program, which is the canonical command line utility using the CFSSL packages.
The multirootca program, which is a certificate authority server that can use multiple signing keys.
The mkbundle program is used to build certificate pool bundles.
The cfssljson program, which takes the JSON output from the cfssl and multirootca programs and writes certificates, keys, CSRs, and bundles to disk.

- cfssljson is a command line tool that converts JSON files to other formats. It is used to convert the JSON output from the cfssl and multirootca programs and writes certificates, keys, CSRs, and bundles to disk.

```bash
wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson

chmod +x cfssl cfssljson

sudo mv cfssl cfssljson /usr/local/bin/

cfssl version

cfssljson -version

```

- Kubectl: Kubernetes command-line tool, allows you to run commands against Kubernetes clusters. You can use kubectl to deploy applications, inspect and manage cluster resources, and view logs.

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y  kubectl
sudo apt-mark hold kubectl

kubectl version --client
```

- Docker: Docker is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers. Containers are isolated from one another and bundle their own software, libraries and configuration files; they can communicate with each other through well-defined channels. All containers are run by a single operating-system kernel and are thus more lightweight than virtual machines.


### AWS CLOUD RESOURCES FOR KUBERNETES CLUSTER

**Step 1 – Configure Network Infrastructure**
- Virtual Private Cloud – VPC



```bash 
# Create a VPC and store the ID as a variable:
VPC_ID=$(aws ec2 create-vpc \
--cidr-block 172.31.0.0/16 \
--output text --query 'Vpc.VpcId'
)

# Add a name tag to the VPC:
NAME=k8s-cluster-from-ground-up

aws ec2 create-tags \
  --resources ${VPC_ID} \
  --tags Key=Name,Value=${NAME}

# Enable DNS hostnames in the VPC:

aws ec2 modify-vpc-attribute \
--vpc-id ${VPC_ID} \
--enable-dns-support '{"Value": true}'

# Enable DNS support in the VPC:
aws ec2 modify-vpc-attribute \
--vpc-id ${VPC_ID} \
--enable-dns-hostnames '{"Value": true}'

# Set the required region
AWS_REGION=us-east-2
```

**Configure DHCP Options Set:**
Dynamic Host Configuration Protocol (DHCP) is a network management protocol used on Internet Protocol networks for automatically assigning IP addresses and other communication parameters to devices connected to the network using a client–server architecture.

AWS automatically creates and associates a DHCP option set for your Amazon VPC upon creation and sets two options: domain-name-servers (defaults to AmazonProvidedDNS) and domain-name (defaults to the domain name for your set region). AmazonProvidedDNS is an Amazon Domain Name System (DNS) server, and this option enables DNS for instances to communicate using DNS names.

By default EC2 instances have fully qualified names like ip-172-50-197-106.eu-central-1.compute.internal.

```bash
# Create a DHCP options set and store the ID as a variable:

DHCP_OPTION_SET_ID=$(aws ec2 create-dhcp-options \
  --dhcp-configuration \
    "Key=domain-name,Values=$AWS_REGION.compute.internal" \
    "Key=domain-name-servers,Values=AmazonProvidedDNS" \
  --output text --query 'DhcpOptions.DhcpOptionsId')

# Add a name tag to the DHCP options set:
aws ec2 create-tags \
  --resources ${DHCP_OPTION_SET_ID} \
  --tags Key=Name,Value=${NAME}

# Associate the DHCP options set with the VPC:
aws ec2 associate-dhcp-options \
  --dhcp-options-id ${DHCP_OPTION_SET_ID} \
  --vpc-id ${VPC_ID}

# Create subnet resources
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 172.31.0.0/24 \
  --output text --query 'Subnet.SubnetId')

# Add a name tag to the subnet:
aws ec2 create-tags \
  --resources ${SUBNET_ID} \
  --tags Key=Name,Value=${NAME}

# Create an Internet gateway and store the ID as a variable:
INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
  --output text --query 'InternetGateway.InternetGatewayId')
aws ec2 create-tags \
  --resources ${INTERNET_GATEWAY_ID} \
  --tags Key=Name,Value=${NAME}

# Attach the Internet gateway to the VPC:
aws ec2 attach-internet-gateway \
  --internet-gateway-id ${INTERNET_GATEWAY_ID} \
  --vpc-id ${VPC_ID}

# Create a route table and store the ID as a variable:
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id ${VPC_ID} \
  --output text --query 'RouteTable.RouteTableId')

# Add a name tag to the route table:
aws ec2 create-tags \
  --resources ${ROUTE_TABLE_ID} \
  --tags Key=Name,Value=${NAME}

# Associate the route table with the subnet:
aws ec2 associate-route-table \
  --route-table-id ${ROUTE_TABLE_ID} \
  --subnet-id ${SUBNET_ID}

# Create a route in the route table that points all traffic to the Internet gateway:
aws ec2 create-route \
  --route-table-id ${ROUTE_TABLE_ID} \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id ${INTERNET_GATEWAY_ID}