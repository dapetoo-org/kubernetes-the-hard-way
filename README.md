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

### Architecture Requirements
- One Kubernetes Master
- Two Kubernetes Worker Nodes
- Configured SSL/TLS certificates for Kubernetes components to communicate securely
- Configured Node Network
- Configured Pod Network

