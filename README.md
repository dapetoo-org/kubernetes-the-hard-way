# PERSISTING DATA IN KUBERNETES

Containers are stateless by design, which means that data does not persist in the containers. Even when you run the containers in kubernetes pods, they still remain stateless unless you ensure that your configuration supports statefulness.

**Volumes** are used to persist data in Kubernetes. 

A Kubernetes volume is a directory that contains data accessible to containers in a given Pod in the orchestration and scheduling platform. Volumes provide a plug-in mechanism to connect ephemeral containers with persistent data stores elsewhere.

**Types of Kubernetes Volume**
Here is a list of some popular Kubernetes Volumes −

**emptyDir** − It is a type of volume that is created when a Pod is first assigned to a Node. It remains active as long as the Pod is running on that node. The volume is initially empty and the containers in the pod can read and write the files in the emptyDir volume. Once the Pod is removed from the node, the data in the emptyDir is erased.

**hostPath** − This type of volume mounts a file or directory from the host node’s filesystem into your pod.

**gcePersistentDisk** − This type of volume mounts a Google Compute Engine (GCE) Persistent Disk into your Pod. The data in a gcePersistentDisk remains intact when the Pod is removed from the node.

**awsElasticBlockStore** − This type of volume mounts an Amazon Web Services (AWS) Elastic Block Store into your Pod. Just like gcePersistentDisk, the data in an awsElasticBlockStore remains intact when the Pod is removed from the node.

**nfs** − An nfs volume allows an existing NFS (Network File System) to be mounted into your pod. The data in an nfs volume is not erased when the Pod is removed from the node. The volume is only unmounted.

**iscsi** − An iscsi volume allows an existing iSCSI (SCSI over IP) volume to be mounted into your pod.

**flocker** − It is an open-source clustered container data volume manager. It is used for managing data volumes. A flocker volume allows a Flocker dataset to be mounted into a pod. If the dataset does not exist in Flocker, then you first need to create it by using the Flocker API.

**glusterfs** − Glusterfs is an open-source networked filesystem. A glusterfs volume allows a glusterfs volume to be mounted into your pod.

**rbd** − RBD stands for Rados Block Device. An rbd volume allows a Rados Block Device volume to be mounted into your pod. Data remains preserved after the Pod is removed from the node.

**cephfs** − A cephfs volume allows an existing CephFS volume to be mounted into your pod. Data remains intact after the Pod is removed from the node.

**gitRepo** − A gitRepo volume mounts an empty directory and clones a git repository into it for your pod to use.

**secret** − A secret volume is used to pass sensitive information, such as passwords, to pods.

**persistentVolumeClaim** − A persistentVolumeClaim volume is used to mount a PersistentVolume into a pod. PersistentVolumes are a way for users to “claim” durable storage (such as a GCE PersistentDisk or an iSCSI volume) without knowing the details of the particular cloud environment.

**downwardAPI** − A downwardAPI volume is used to make downward API data available to applications. It mounts a directory and writes the requested data in plain text files.

**azureDiskVolume** − An AzureDiskVolume is used to mount a Microsoft Azure Data Disk into a Pod.

## Persistent Volume and Persistent Volume Claim**

Persistent Volume (PV) − It’s a piece of network storage that has been provisioned by the administrator. It’s a resource in the cluster which is independent of any individual pod that uses the PV.

Persistent Volume Claim (PVC) − The storage requested by Kubernetes for its pods is known as PVC. The user does not need to know the underlying provisioning. The claims must be created in the same namespace where the pod is created.

**nginx-deplyment.yaml** – without volume

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

**nginx-deplyment.yaml** – with volume

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    tier: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      volumes:
      - name: nginx-volume
        # This AWS EBS volume must already exist.
        awsElasticBlockStore:
          volumeID: "<volume id>"
          fsType: ext4
```

```bash
kubectl apply -f nginx-deployment.yaml 

kubectl get deployments.apps

kubectl get pods

kubectl logs -f nginx-deployment-5d6cf97577-h8sp4

kubectl describe pod nginx-deployment-5d6cf97577-h8sp4

kubectl exec -it nginx-deployment-5d6cf97577-h8sp4 -- /bin/bash

kubectl get pods -o wide

kubectl describe nodes ip-192-168-71-140.us-east-2.compute.internal

kubectl describe deployments.apps nginx-deployment-with-volume

kubectl describe pods nginx-deployment-with-volume-79d57cd9cf-fkhxt
```

## MANAGING VOLUMES DYNAMICALLY WITH PVS AND PVCS

PVs are volume plugins that have a lifecycle completely independent of any individual Pod that uses the PV. This means that even when a pod dies, the PV remains. A PV is a piece of storage in the cluster that is either provisioned by an administrator through a manifest file, or it can be dynamically created if a storage class has been pre-configured.

Creating a PV manually is like what we have done previously where with creating the volume from the console. As much as possible, we should allow PVs to be created automatically just be adding it to the container spec iin deployments. But without a storageclass present in the cluster, PVs cannot be automatically created.

```bash
kubectl get storageclass
```

**kubernetes-storage-class.yaml**

```yaml
  kind: StorageClass
  apiVersion: storage.k8s.io/v1
  metadata:
    name: gp2
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
  provisioner: kubernetes.io/aws-ebs
  parameters:
    type: gp2
    fsType: ext4 
```

**Lifecycle of a PV and PVC**

PVs and PVCs follow a lifecycle that starts with provisioning, moves on to binding, which is followed by using, and then can shift to reclaiming, retaining, and finally deletion.

**Provisioning:** Here are the two main options available for provisioning PVs:

- Static provisioning—involves manually creating PVs that contain the specs of the storage available for cluster users. This type of PV is located and available for consumption from within the Kubernetes API. 

- Dynamic provisioning—enabled by the use of PVCs. If there is no available manually-created PV, Kubernetes uses PVCs to meet demands.

**Binding:** The binding process ensures that PVs meet user demands without wasting volume resources. The goal is to match PVCs with PVs that contain the amount of required resources, and then bind them together. This match then becomes exclusive, using a ClaimRef-based one-to-one mapping that creates a bi-directional binding. 

**Using:** To meet user demands, clusters mount only a bound volume for a pod. Once this happens, the bound PV is reserved for the user. Users can schedule pods and obtain claimed PVs by adding a persistentVolumeClaim section in the volumes block of the pod template.

**Reclaiming:** Once users no longer need their volume, they can delete PVC objects from the reclamation API. The cluster uses a reclaim policy to learn what to do with the volume after its claim is released. At the moment, volumes can be either retained, recycled, or deleted.

**Retain:** The retain reclaim policy enables manual reclamation of a resource. When a PVC is deleted, the PV continues existing even though the volume is released. Because the PV still contains the data of the previous user, the volume is not immediately available for another claim. To reclaim a volume, you need to manually configure the process, mainly by cleaning up the data. 

**Delete:** The delete reclaim policy enables you to remove the PV object and any associated storage assets existing in the external infrastructure. Note that dynamically provisioned PVs inherit the reclaim policy of their StorageClass, which defaults to delete.

**NOTES:**

- When PVCs are created with a specific size, it cannot be expanded except the storageClass is configured to allow expansion with the allowVolumeExpansion field is set to true in the manifest YAML file. This is "unset" by default in EKS.

- When a PV has been provisioned in a specific availability zone, only pods running in that zone can use the PV. If a pod spec containing a PVC is created in another AZ and attempts to reuse an already bound PV, then the pod will remain in pending state and report volume node affinity conflict. Anytime you see this message, this will help you to understand what the problem is.

- PVs are not scoped to namespaces, they a clusterwide wide resource. PVCs on the other hand are namespace scoped.

- When a PVC is created, it is bound to a PV. The PV is then bound to the PVC. This is a one-to-one binding. The PVC is bound to a PV with the same storage class, access mode, and size. If the PV is already bound to a PVC, the PVC will remain in pending state until the PV is released.

```bash
kubectl apply -f nginx-pvc.yaml

kubectl get pvc

kubectl describe pvc nginx-volume-claim
```

## CONFIGMAPS

ConfigMaps are used to store non-confidential data in key-value pairs. ConfigMaps can be consumed in pods in the form of environment variables, command-line arguments, or as configuration files in a volume. ConfigMaps can be created from literal values, files, or directories. ConfigMaps can be mounted as volumes. The data stored in a ConfigMap object can be referenced in a volume of type configMap and then consumed by containerized applications running in a pod.

A ConfigMap is an API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume. ConfigMaps can be created from literal values, files, or directories. ConfigMaps can be mounted as volumes. The data stored in a ConfigMap object can be referenced in a volume of type configMap and then consumed by containerized applications running in a pod.

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: website-index-file
data:
  # file to be mounted inside a volume
  index-file: |
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to PETERDADA.ME!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to PETERDADA.ME!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. This page is served through Kubernetes using Configmap. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
```

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-with-configmap
  labels:
    tier: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
          - name: config
            mountPath: /usr/share/nginx/html
            readOnly: true
      volumes:
      - name: config
        configMap:
          name: website-index-file
          items:
          - key: index-file
            path: index.html
```

### Project Screenshots 

![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/01.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/02.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/03.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/04.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/05.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/06.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/07.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/08.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/09.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/10.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/11.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/12.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/13.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/14.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/15.png)
![Screenshots](https://github.com/scholarship-task/kubernetes-the-hard-way/blob/data-persistence/screenshots/16.png)