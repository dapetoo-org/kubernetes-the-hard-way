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

Multiple scheduler

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-scheduler
  name: my-scheduler
  namespace: kube-system
spec:
  serviceAccountName: my-scheduler
  containers:
  - command:
    - /usr/local/bin/kube-scheduler
    - --config=/etc/kubernetes/my-scheduler/my-scheduler-config.yaml
    image: k8s.gcr.io/kube-scheduler:v1.24.0 # changed
    livenessProbe:
      httpGet:
        path: /healthz
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 15
    name: kube-second-scheduler
    readinessProbe:
      httpGet:
        path: /healthz
        port: 10259
        scheme: HTTPS
    resources:
      requests:
        cpu: '0.1'
    securityContext:
      privileged: false
    volumeMounts:
      - name: config-volume
        mountPath: /etc/kubernetes/my-scheduler
  hostNetwork: false
  hostPID: false
  volumes:
    - name: config-volume
      configMap:
        name: my-scheduler-config
```

Using custom-scheduler

```
apiVersion: v1 
kind: Pod 
metadata:
  name: nginx 
spec:
  schedulerName: my-scheduler
  containers:
  - image: nginx
    name: nginx
```

Logging and Monitoring

```

git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git

kubectl top node

kubectl top pod

kubectl logs pods/webapp-1 -f

```


Application Lifecycle Management

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
spec:
  replicas: 4
  selector:
    matchLabels:
      name: webapp
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        name: webapp
    spec:
      containers:
      - image: kodekloud/webapp-color:v2
        name: simple-webapp
        ports:
        - containerPort: 8080
          protocol: TCP
```

Strategy: Recreate, RollingUpdate


```
apiVersion: v1 
kind: Pod 
metadata:
  name: ubuntu-sleeper-2 
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command:
      - "sleep"
      - "5000"

# Create a pod with the ubuntu image to run a container to sleep for 5000 seconds. Modify the file ubuntu-sleeper-2.yaml.

```

Environment Variables

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: webapp-color
  name: webapp-color
  namespace: default
spec:
  containers:
  - env:
    - name: APP_COLOR
      value: green
    image: kodekloud/webapp-color
    name: webapp-color
```

```
# Create a new ConfigMap for the webapp-color POD. Use the spec given below.
- ConfigName Name: webapp-config-map
- Data: APP_COLOR=darkblue

kubectl create configmap webapp-config-map --from-literal=APP_COLOR=darkblue


```
# Using config map
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: webapp-color
  name: webapp-color
  namespace: default
spec:
  containers:
  - envFrom:
    - configMapRef:
         name: webapp-config-map
    image: kodekloud/webapp-color
    name: webapp-color
```

Secrets

```
kubectl get secrets

kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123

```
apiVersion: v1 
kind: Pod 
metadata:
  labels:
    name: webapp-pod
  name: webapp-pod
  namespace: default 
spec:
  containers:
  - image: kodekloud/simple-webapp-mysql
    imagePullPolicy: Always
    name: webapp
    envFrom:
    - secretRef:
        name: db-secret
```

Multi-Container

```
kind: Pod
apiVersion: v1
metadata:
  name: yellow
spec:
  containers:
  - name: lemon
    image: busybox
    command: ['sleep', '1000']
  - name: gold
    image:  redis
```

```
apiVersion: v1
kind: Pod
metadata:
  name: app
  namespace: elastic-stack
  labels:
    name: app
spec:
  containers:
  - name: app
    image: kodekloud/event-simulator
    volumeMounts:
    - mountPath: /log
      name: log-volume

  - name: sidecar
    image: kodekloud/filebeat-configured
    volumeMounts:
    - mountPath: /var/log/event-simulator/
      name: log-volume

  volumes:
  - name: log-volume
    hostPath:
      # directory location on host
      path: /var/log/webapp
      # this field is optional
      type: DirectoryOrCreate
```

Init Containers

```
apiVersion: v1
kind: Pod
metadata:
  name: red
  namespace: default
spec:
  containers:
  - command:
    - sh
    - -c
    - echo The app is running! && sleep 3600
    image: busybox:1.28
    name: red-container
  initContainers:
  - image: busybox
    name: red-initcontainer
    command: 
      - "sleep"
      - "20"
```

CLUSTER MAINTENANCE, PRACTICE TEST OS UPGRADES

```

#Empty the node of all applications and mark it unschedulable.
kubectl drain node01 --ignore-daemonsets


# Configure the node node01 to be schedulable again.
kubectl uncordon node01


Mark node01 as unschedulable so that no new pods are scheduled on this node.

Make sure that hr-app is not affected.

Do not drain node01, instead use the kubectl cordon node01 command. This will ensure that no new pods are scheduled on this node and the existing pods will not be affected by this operation.

kubectl cordon node01

```

TEST CLUSTER UPGRADE PROCESS 

kubeadm upgrade plan

kubectl drain controlplane --ignore-daemonsets

apt-get install kubeadm=1.25.0-00
kubeadm upgrade apply v1.25.0

apt-get install kubelet=1.25.0-00 

systemctl daemon-reload
systemctl restart kubelet

BACKUP AND RESTORE

kubectl -n kube-system logs etcd-controlplane | grep -i 'etcd-version'

kubectl describe pod etcd-controlplane -n kube-system

# Create a backup of the etcd-controlplane

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db

# Restart the cluster with the latest snapshot

ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup \
snapshot restore /opt/snapshot-pre-boot.db

kubectl config get-clusters

ETCDCTL_API=3 etcdctl \
 --endpoints=https://127.0.0.1:2379 \
 --cacert=/etc/etcd/pki/ca.pem \
 --cert=/etc/etcd/pki/etcd.pem \
 --key=/etc/etcd/pki/etcd-key.pem \
  member list

  kubectl config use-context cluster1

  kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep advertise-client-urls
      --advertise-client-urls=https://10.1.218.16:2379


kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep pki
      --cert-file=/etc/kubernetes/pki/etcd/server.crt
      --key-file=/etc/kubernetes/pki/etcd/server.key
      --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
      --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
      --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      /etc/kubernetes/pki/etcd from etcd-certs (rw)
    Path:          /etc/kubernetes/pki/etcd


SECURITY

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text

What is the Common Name (CN) configured on the Kube API Server Certificate?


openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text


CReating a CSR 

akshay.csr
-----BEGIN CERTIFICATE REQUEST-----
MIICVjCCAT4CAQAwETEPMA0GA1UEAwwGYWtzaGF5MIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA0zzsAEhlY6PuQoXmY39gXRSzk3jlWHAK32ITryQPkp5I
HbSGA18TZ/Dekq4PQKbyGogzxlE/xD+BRE5yZ/sL7gQLiIrNx4uv2D3H4JAt8E7Y
NaHwOD2K3SnLoKK04ZUu0I4NleK6CroylbY+yOHNQKnQAf/eECwmSt5TGmfQDnbV
J7CjibOxa4/F4rZXw4F7ncV1pYWGrV5uoMlfc5XGl0rVpthyiK1A6k6sOKTM6S18
xhcE/Fnf0m43X6/L01BatDdEWzi/IEbIiaXWcZg916LhYtMcWD2ldjpR4pBjBu9q
yWpmQ40DDa1yVoS021OpcYjhC3cU3RGo2zUmTkBJoQIDAQABoAAwDQYJKoZIhvcN
AQELBQADggEBAJJqGhjp/yTMgxFbQZvLwcJRsXEZHqyo5fHHtdnhyyo29Ogs1CRe
Of27gDH4ColmnHsBN0rhzKmcIhPszL8C4Lg3SREZeqwyQNNaqNmz7bI4JftUB6k8
aZbTU8NKvXUmyHyr7IHR5MGGILEiF0dr4vBGnEJnaRTe+Z7nPfbmwb8DWzFzXvdk
AwqKHPMN8gx78FGOpqWDE6mtnQinmE0L9isOehRFTZWBl3VXNdwJRNAfJAObsvbL
PeMnvt5v0WzvKL5Fi96CAk7k6oDmBHq3/xjJ/xWFw3dE9SI2rBhDV9ecQFH3Og8w
Kou4G2O5mkSe9mr5RSmzFrVWCMRyAzw2JGk=
-----END CERTIFICATE REQUEST-----


akshay.key

-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA0zzsAEhlY6PuQoXmY39gXRSzk3jlWHAK32ITryQPkp5IHbSG
A18TZ/Dekq4PQKbyGogzxlE/xD+BRE5yZ/sL7gQLiIrNx4uv2D3H4JAt8E7YNaHw
OD2K3SnLoKK04ZUu0I4NleK6CroylbY+yOHNQKnQAf/eECwmSt5TGmfQDnbVJ7Cj
ibOxa4/F4rZXw4F7ncV1pYWGrV5uoMlfc5XGl0rVpthyiK1A6k6sOKTM6S18xhcE
/Fnf0m43X6/L01BatDdEWzi/IEbIiaXWcZg916LhYtMcWD2ldjpR4pBjBu9qyWpm
Q40DDa1yVoS021OpcYjhC3cU3RGo2zUmTkBJoQIDAQABAoIBAGVJEOAR1ouwTs4W
5iFPMiVvh6tujImbL5tsq4OPBuiGfI3BwYBcVjHAjPhH/YhChFO0ex7cVncC/DiE
ZNb2yQGXbvBJneHQWMCW3wAOIfjX1VPiEgzldXAWWkzrt09y+L+HXXxA+nOqVBb1
C6XGn2QiCFrtFM0sXjAH6lD+9gP4l5f+P22VphAHNpYiUoaLNlMgeAMbtYomHaR/
V2HiawlTUuZlnhKfj6Ejxdxo+BFOu0ALIw0qTxlNnQYtHgGwiHbXfmjyV/EtIUdP
IRr9UBm+303BhyuGQSeMWsno45X8MCOKDgTJ5+lFC3bB/wp5WylXmR5ZXXeAnWha
d5o3pAECgYEA8MZQjzhQ+cXDJskIlYaZwp6ep9s9Ne++63Yn9BIR8GkvRwDNiKCf
XZrr+kswWNROFT8td4VK+H7WaT8JhPd6qDef39nw89U1eL5vWgbCKe+UrxwaOtCS
FYGQV5XE9R6A2xQlQ3AJLWqHu/xdny/4WHzC66lpWxY3rMZAsGlfJG0CgYEA4Jh2
1FoT1ARSkEMvxhN5Nuy3qHtkh7L4WFOVdg8vydT21JC6EAfgxRBmjGLoCLkNtJJU
rAdffO9A0A1GkY6NJFll8tbpaowzDSaVDH9xnu2rMJv2O+JIIpz2FLWQJGbem/Z9
kDI2Ti6DIcqpg5R6SvAwTQ69/OXjuH1MUHJPsYUCgYB78+yHPtvZKmmELxyfNdM0
sUpGagTCHrGwMHzzFtZraQswx4YIX4CLxPTVPx4drPah04uJq3JkKZAiUJSLAoj/
ztscd+um682CYq+arj4JLtDhsVsDilqafcAchvsFofV+U4m3hRcEbYKBUbO0/xIg
I+KJRgb6IJ768HlfGHAlpQKBgBjEV15FbKhVrbEg55TFMvm+kuYubUCVmNNMrE+v
jwqHxIxeRVZdOAkjLNvQUFwd5AgElve9fGcvjwsiW6TTfncCsL5durG4Mi0CEy+k
oifvd5BNspKZ+nButKhF+VY6TdQPE3uiPeDTOjywt46+AdpfsEPfG05XH4yJrK+2
W1ltAoGAJrJo5v3SlAHzlhLFGguQjgUaB3SUG6YHEmiKYjQ9vDKV2ieD5vtXQRiW
bvNrNN0uzJjbYWBrKyZKkf/C1AOmubc5unNzJ/C03Jx1GC4T3khctmwCkB/kVxEt
GQcBNwyMLcZQWJktrRocLrjW0p2jM7PmIYfzvq7sWk7dOa4Jfec=
-----END RSA PRIVATE KEY-----

cat akshay.csr | base64 -w 0

It's the output of the base64 that will be used for the request


```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: akshay
spec:
  groups:
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZV3R6YUdGNU1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQXY4azZTTE9HVzcrV3JwUUhITnI2TGFROTJhVmQ1blNLajR6UEhsNUlJYVdlCmJ4RU9JYkNmRkhKKzlIOE1RaS9hbCswcEkwR2xpYnlmTXozL2lGSWF3eGVXNFA3bDJjK1g0L0lqOXZQVC9jU3UKMDAya2ZvV0xUUkpQbWtKaVVuQTRpSGxZNDdmYkpQZDhIRGFuWHM3bnFoenVvTnZLbWhwL2twZUVvaHd5MFRVMAo5bzdvcjJWb1hWZTVyUnNoMms4dzV2TlVPL3BBdEk4VkRydUhCYzRxaHM3MDI1ZTZTUXFDeHUyOHNhTDh1blJQCkR6V2ZsNVpLcTVpdlJNeFQrcUo0UGpBL2pHV2d6QVliL1hDQXRrRVJyNlMwak9XaEw1Q0ErVU1BQmd5a1c5emQKTmlXbnJZUEdqVWh1WjZBeWJ1VzMxMjRqdlFvbndRRUprNEdoayt2SU53SURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBQi94dDZ2d2EweWZHZFpKZ1k2ZDRUZEFtN2ZiTHRqUE15OHByTi9WZEdxN25oVDNUUE5zCjEwRFFaVGN6T21hTjVTZmpTaVAvaDRZQzQ0QjhFMll5Szg4Z2lDaUVEWDNlaDFYZnB3bnlJMVBDVE1mYys3cWUKMkJZTGJWSitRY040MDU4YituK24wMy9oVkN4L1VRRFhvc2w4Z2hOaHhGck9zRUtuVExiWHRsK29jQ0RtN3I3UwpUYTFkbWtFWCtWUnFJYXFGSDd1dDJveHgxcHdCdnJEeGUvV2cybXNqdHJZUXJ3eDJmQnErQ2Z1dm1sVS9rME4rCml3MEFjbVJsMy9veTdqR3ptMXdqdTJvNG4zSDNKQ25SbE41SnIyQkZTcFVQU3dCL1lUZ1ZobHVMNmwwRERxS3MKNTdYcEYxcjZWdmJmbTRldkhDNnJCSnNiZmI2ZU1KejZPMUU9Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth

```
kubectl get csr

kubectl certificate approve akshay - approve request

kubectl get csr agent-smith -o yaml - check request details in yaml

kubectl certificate deny agent-smith - deny request

kubectl delete csr agent-smith - delete request


Kubeconfig file

kubectl config --kubeconfig=/root/my-kube-config use-context research


ROLES

kubectl get roles

kubectl describe pod kube-apiserver-controlplane -n kube-system

kubectl describe role kube-proxy -n kube-system

kubectl describe rolebinding kube-proxy -n kube-system

kubectl get pods --as dev-user


Create the necessary roles and role bindings required for the dev-user to create, list and delete pods in the default namespace.

Use the given spec:
  Role: developer
  Role Resources: pods
  Role Actions: list
  Role Actions: create
  Role Actions: delete
  RoleBinding: dev-user-binding
  RoleBinding: Bound to dev-user

  Imperative

  ```
  kubectl create role developer --namespace=default --verb=list,create,delete --resource=pods  (Role)

  kubectl create rolebinding dev-user-binding --namespace=default --role=developer --user=dev-user (RoleBinding)


  #Declarative way

  ```
  kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "create","delete"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-user-binding
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```


kubectl edit role developer -n blue

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: blue
rules:
- apiGroups:
  - apps
  resourceNames:
  - dark-blue-app
  resources:
  - pods
  verbs:
  - get
  - watch
  - create
  - delete
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - get
  - watch
  - create
  - delete


CLUSTER ROLES

kubectl get clusterroles --no-headers | wc -l

kubectl get clusterroles --no-headers -o json | jq '.items | length'

kubectl get clusterrolebindings --no-headers | wc -l

kubectl get clusterrolebindings --no-headers -o json | jq '.items | length'

kubectl describe clusterrolebinding cluster-admin

kubectl describe clusterrole cluster-admin



A new user michelle joined the team. She will be focusing on the nodes in the cluster. Create the required ClusterRoles and ClusterRoleBindings so she gets access to the nodes.



---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: node-admin
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "watch", "list", "create", "delete"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: michelle-binding
subjects:
- kind: User
  name: michelle
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-admin
  apiGroup: rbac.authorization.k8s.io

```
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: storage-admin
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["get", "watch", "list", "create", "delete"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "watch", "list", "create", "delete"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: michelle-storage-admin
subjects:
- kind: User
  name: michelle
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: storage-admin
  apiGroup: rbac.authorization.k8s.io
```


SERVICE ACCOUNTS

kubectl get serviceaccounts

kubectl describe serviceaccount  <sva-name>

kubectl get po -o yaml

kubectl create serviceaccount dashboard-sa

kubectl create token dashboard-sa

kubectl set serviceaccount deploy/web-dashboard dashboard-sa


SECRETS

kubectl create secret docker-registry private-reg-cred --docker-username=dock_user --docker-password=dock_password --docker-server=myprivateregistry.com:5000 --docker-email=dock_user@myprivateregistry.com


apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred