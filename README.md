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

