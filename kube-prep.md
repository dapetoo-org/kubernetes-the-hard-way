# Kubernetes Exam Preparation

Pods

```
kubectl get pods --field-selector=status.phase=Running
kubectl describe pods [pod-name]
```

Replicaset

Scaling 

```
kubectl scale replicaset --replicas=5 new-replica-set
```

Deployments

```
kubectl create deployment --image=httpd:2.4-alpine --replicas=3 httpd-frontend -o yaml --dry-run=client > deployment.yaml
```

Namespace

```
kubectl get pods --namespace research

kubectl run --image=redis redis --namespace=finance

kubectl get pods --all-namespaces

```

Service

```
kubectl describe svc kubernetes
```

Imperative Commands

```
kubectl run --image=nginx:alpine nginx-pod

kubectl run --image=redis:alpine --labels=tier=db redis

kubectl expose pod redis --port=6379 --type=ClusterIP --name=redis-service

kubectl create deployment --image=kodekloud/webapp-color --replicas=3 webapp -o yaml --dry-run=server

kubectl create deployment --image=kodekloud/webapp-color --replicas=3 webapp -o yaml --dry-run=server > dep.yaml

kubectl run --image=nginx --port=8080 custom-nginx

kubectl create ns dev-ns

kubectl create deployment --image=redis --replicas=2 --namespace=dev-ns redis-deploy -o yaml --dry-run=server

k run --image=httpd:alpine httpd

k expose pod httpd --type=ClusterIP --port=80 --name=httpd

```

Cluster Installation

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00
sudo apt-mark hold kubelet kubeadm kubectl
```

ssh node01

Bootstrap Cluster

```
kubeadm init --apiserver-advertise-address 10.17.229.8 (IP of control plane node)

kubeadm init --apiserver-advertise-address 10.17.229.8 --apiserver-cert-extra-sans controlplane --pod-network-cidr 10.244.0.0/16

# Worker node
kubeadm join 10.17.229.8:6443 --token cqne5c.vgvtw1uzikwozmol \
        --discovery-token-ca-cert-hash sha256:ace08b5d6a4083e526f8b07e8caf7dd8eaa6e9f2a015a782a4ba2c562e6be9fe 

# Flannel Networking

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```

Scheduling
```
kubectl get pods --namespace kube-system

#No scheduler

apiVersion: v1
kind: Pod
metadata:
 name: nginx
 labels:
  name: nginx
spec:
 containers:
 - name: nginx
   image: nginx
   ports:
   - containerPort: 8080
 nodeName: node02
 ```

 Selector and Labels

 ```
 kubectl get pods --selector env=dev

 kubectl get all --selector env=prod

# Run the command to get exact number of objects
 kubectl get all --selector env=prod --no-headers | wc -l

 # Multiple selectors
 kubectl get pods --selector env=prod,bu=finance,tier=frontend

 ```

 Taints and Tolerations

 ```
 kubectl describe nodes node01

 # Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule

 kubectl taint node node01 spray=mortein:NoSchedule

```

**taints-tolerations.yaml**

```
apiVersion: v1
kind: Pod
metadata:
  name: bee
spec:
  containers:
  - image: nginx
    name: bee
  tolerations:
  - key: spray
    value: mortein
    effect: NoSchedule
    operator: Equal
```

# Untaint control plane node 

kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule- 
 
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule


# **-** This flag will remove the taint from the node


Node Affinity

```
kubectl label nodes node01 color=blue

kubectl describe node node01 | grep -i taints
```



**node-affinity.yaml**
Set Node Affinity to the deployment to place the pods on node01 only.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: color
                operator: In
                values:
                - blue
```

kubectl get pods -o wide

Deploy a DaemonSet for FluentD Logging. Use the given specifications:
Name: elasticsearch
Namespace: kube-system
Image: k8s.gcr.io/fluse the given specifications.
Name: elasticsearch
Namespace: kube-system
Image: k8entd-elasticsearch:1.20

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: red
spec:
  replicas: 2
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: Exists

# Create a new deployment named red with the nginx image and 2 replicas, and ensure it gets placed on the # controlplane node only.

Use the label key - node-role.kubernetes.io/control-plane - which is already set on the controlplane node.

```


 Resources Limit

 Daemonsets

 kubectl describe daemonset kube-proxy --namespace=kube-system

 kubectl create deployment elasticsearch --image=k8s.gcr.io/fluentd-elasticsearch:1.20 -n kube-system --dry-run=client -o yaml > fluentd.yaml

 ```
 apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: elasticsearch
  name: elasticsearch
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - image: k8s.gcr.io/fluentd-elasticsearch:1.20
        name: fluentd-elasticsearch
```

Static PODS

kubectl get pods --all-namespaces (the pod from the list that does not end with -controlplane)

- kube-proxy
- coredns
- kube-flannel


Create a pod definition file called static-busybox.yaml with the provided specs and place it under /etc/kubernetes/manifests directory

kubectl run --restart=Never --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml