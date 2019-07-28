# Kaniko - Getting Started

This repository contains examples that show how to use Kaniko for building docker images using KNative and Kubernetes.

## Docker

The following docker images have been provided as build examples:
- [edowson/ubuntu-network-utils:xenial](./docker/ubuntu/network-utils)

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

```bash
cd k8s/pod
sudo nano k8s-pod-kaniko.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    env:
      - name: REPOSITORY
        value: ubuntu
      - name: TAG
        value: '18.04'
    args: ["--dockerfile=/workspace/kaniko-getting-started/docker/ubuntu/network-utils/Dockerfile",
           "--build-arg - REPOSITORY=$(REPOSITORY)",
           "--build-arg - TAG=$(TAG)",
           "--context=dir://workspace",
           "--destination=image",
           "--tarPath=/workspace/ubuntu-network-utils-docker-image.tar",
           "--no-push"]
    volumeMounts:
      - name: workspace
        mountPath: /workspace
  restartPolicy: Never
  volumes:
    - name: workspace
      persistentVolumeClaim:
        claimName: pvc-kaniko-workspace
```

Create pod
```bash
kubectl create -f ./k8s-pod-kaniko.yaml
```

Check pod status:
```bash
kubectl get pods

NAME                                   READY   STATUS    RESTARTS   AGE
kaniko                                 1/1     Running   0          10s
```

Check logs:
```bash
kubectl logs kaniko
```

The docker image tarball will be generate in the persistent volume storage location:
```
/mnt/storage/pv/pv-kaniko/ubuntu-network-utils-bionic.tar
```

---

## Issues

01. [Build image into local #636 - kaniko](https://github.com/GoogleContainerTools/kaniko/issues/636)

Solution 01:
```bash
--destination=image --tarPath=/your_workspace/image.tar
can save the image to the local directory. And you need to manually load it to docker daemon.
```

Solution 02:
```bash
docker run --rm -w /workspace -v (pwd):/workspace gcr.io/kaniko-project/executor --tarPath=/path/to/image.tar --context=auth-provider --no-push
```

02. [Error: unknown flag when using --build-arg in buildtemplate #565](https://github.com/knative/build/issues/565)

Solution 01: Create your build template as shown below:
```
name: 'gcr.io/kaniko-project/executor:latest'
  args:
   - --dockerfile=${DOCKERFILE}
    - --build-arg
    -  A_TARGET=green
    - --build-arg
    - B_TARGET=blue
    - --destination=${IMAGE}
    - --cache=true
```

Without being passed as separate items into args, it's interpreted as one arg that includes a space, as if you'd passed `executor "--build-arg A_TARGET=green"` instead of executor `--build-arg A_TARGET=green` like you expect, and the tool requires.

---

## Repositories

- [debuggy/kaniko-example](https://github.com/debuggy/kaniko-example)
> An example of running kaniko in kubernetes.
