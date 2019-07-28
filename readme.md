# Kaniko - Getting Started

This repository contains examples that show how to use Kaniko for building docker images using KNative and Kubernetes.

## Docker

The following docker images have been provided as build examples:
- [edowson/ubuntu-network-utils:xenial](./docker/ubuntu/xenial/network-utils)

## Setup

We will need to
- [create a persistent volume](#create-persistent-volume), to allocate physical storage on the kubernetes cluster for a kaniko workspace,
- [create a persistent volume claim](#create-persistent-volume-claim),
- [create a pod definition](#create-pod-definition), for a kaniko container for building docker images.

### Create Persistent Volume


Create storage volume:
```bash
mkdir -p /mnt/storage/pv/pv-kaniko
```

Create persistent volume specification:
```bash
cd k8s/storage
sudo nano k8s-ssd-pv-kaniko-workspace.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-kaniko-workspace
  labels:
    type: local
spec:
  storageClassName: fast
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/storage/pv/pv-kaniko"
```


Create persistent volume:
```bash
kubectl apply -f ./k8s-ssd-pv-kaniko-workspace.yaml
```

Check:
```bash
kubectl get pv
NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM    STORAGECLASS   REASON   AGE
pv-kaniko-workspace        10Gi       RWO            Retain           Available            fast                    3s

```

## Create Persistent Volume Claim

Define a `k8s-ssd-pvc-kaniko-workspace.yaml` file for the PersistentVolumeClaim:

```bash
cd k8s/storage
sudo nano k8s-ssd-pvc-kaniko-workspace.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-kaniko-workspace
spec:
  storageClassName: fast
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

This persistent volume claim (PVC) will search for a compatible persistent volume (PV) to bind with - using the access mode and storage request as matching criteria. Note that we define the storageClassName as an empty string to avoid the PVC searching for storage on the default storage class. Alternatively, a storage class could be defined for both the PV and PVC.

Once bound, the PV will not be able to bind with another PVC, but multiple pods in the same cluster can use the same PVC.


Create the persistent volume claim:
```bash
kubectl apply -f ./k8s-ssd-pvc-kaniko-workspace.yaml
```

Verify that the persistent volume claim was created.

```bash
kubectl get pvc
NAME                        STATUS   VOLUME                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-kaniko-workspace        Bound    pv-kaniko-workspace        10Gi       RWO            fast           3s
```

### Create Pod Definition

Create a pod definition for starting a kaniko container for building docker images.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kaniko

```


---

## Repositories

- [debuggy/kaniko-example](https://github.com/debuggy/kaniko-example)
> An example of running kaniko in kubernetes.
