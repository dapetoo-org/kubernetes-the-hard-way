# Kubernetes Exam Preparation

Pods
Replicaset

Scaling 

```
kubectl scale replicaset --replicas=5 new-replica-set
```

Deployments

```
kubectl create deployment --image=httpd:2.4-alpine --replicas=3 httpd-frontend -o yaml --dry-run=client > deployment.yaml
```

```


