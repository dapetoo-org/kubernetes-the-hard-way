# DEPLOYING APPLICATIONS INTO KUBERNETES CLUSTER

**Deploying the Tooling app using Kubernetes objects**

**Kubernetes objects** are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster. Specifically, they can describe:

- What containerized applications are running (and on which nodes)
- The resources available to those applications
- The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance

These objects are "record of intent" – once you create the object, the Kubernetes system will constantly work to ensure that the object exists. By creating an object, you are effectively telling the Kubernetes system what you want your cluster’s workload to look like; this is your cluster’s desired state.

**Kubernetes objects** are represented in the Kubernetes API as JSON and are typically described using YAML or JSON. The format of the object schema is the same for both YAML and JSON. The YAML format is the standard format for configuration files and is preferred for readability and ease of editing. The JSON format is also accepted by the Kubernetes API.

**COMMON KUBERNETES OBJECTS**

- Pod
- Namespace
- ResplicaSet (Manages Pods)
- DeploymentController (Manages Pods)
- StatefulSet
- DaemonSet
- Service
- ConfigMap
- Volume
- Job/Cronjob

**Common fields for every Kubernetes object**
Every Kubernetes object includes object fields that govern the object’s configuration:

**kind:** Represents the type of kubernetes object created. It can be a Pod, DaemonSet, Deployments or Service.

**version:** Kubernetes api version used to create the resource, it can be v1, v1beta and v2. Some of the kubernetes features can be released under beta and available for general public usage.

**metadata:** provides information about the resource like name of the Pod, namespace under which the Pod will be running labels and annotations.

**spec:** consists of the core information about Pod. Here we will tell kubernetes what would be the expected state of resource, Like container image, number of replicas, environment variables and volumes.

**status:** consists of information about the running object, status of each container. Status field is supplied and updated by Kubernetes after creation. This is not something you will have to put in the YAML manifest.

**Running Nginx web server**

```
kubectl run --image=nginx nginx
kubectl run --image=nginx nginx --dry-run=client -o yaml > nginx-pod.yaml
kubectl expose pod nginx --port=80 --type=LoadBalancer
kubectl get pod nginx --show-labels
kubectl get svc nginx -o wide
kubectl get pod nginx -o wide
kubectl describe pod nginx

kubectl apply -f nginx-pod.yaml
kubectl delete -f nginx-pod.yaml

kubectl  get replicasets.apps

kubectl get replicasets.apps -o wide

kubectl scale deployment nginx --replicas=10

kubectl get pods --watch

kubectl exec -it nginx-85b98978db-84dq7 /bin/bash

cd usr/share/nginx/html/

kubectl expose deployment nginx --port=80 --type=LoadBalancer


``` 

**Tooling App with Kubernetes**

```
kubectl create deployment tooling-app --image=dapetoo/tooling --replicas=2 --dry-run=client -o yaml > tooling-app.yaml

kubectl apply -f tooling-app.yaml

kubectl expose deployment tooling-app --type=LoadBalancer --port=8081 --dry-run=client -o yaml > tooling-service.yaml

kubectl apply -f tooling-service.yaml 

```

## Project Screenshots

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/01.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/02.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/03.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/04.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/05.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/06.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/07.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/Screenshot%20from%202022-12-11%2019-55-48.png)

![Screenshot](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/tooling-kubernetes/screenshots/Screenshot%20from%202022-12-11%2019-55-48.png)


