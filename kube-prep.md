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



