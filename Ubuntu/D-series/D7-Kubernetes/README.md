## D7 - Kubernetes Fundamentals

## What is Kubernetes?

Kubernetes is an open-source container orchestration system. It automates the deployment, scaling, and management of containerized applications across a cluster of machines. Originally developed by Google, now maintained by the Cloud Native Computing Foundation (CNCF)

---

## Cluster Structure

A kubernetes cluster consists of two types of machines:

- **Control Plane** - manages the cluster
- **Worker Nodes** - run the application workloads

---

## Control Plane Components 

| Component | Role |
|---|---|
| API Server | Central communication hub. All requests go through it. |
| etcd | Key-value store. Holds entire cluster state. |
| Scheduler | Assigns newly created Pods to suitable nodes. |
| Controller Manager | Watches cluster state and reconciles actual vs desired state. |

---

## Worker Node Components 

| Component | Role |
|---|---|
| kubelet | Agent on every node. Ensures Pods are running and healthy. |
| kube-proxy | Manages network rules and traffic routing on the node. |
| Container Runtime | Runs the actual containers (containerd, CRI-O). |

---

## Core Concepts

### Desired State vs Actual State
Kubernetes operates on a declarative model. You define the desired state in a YAML manifest. Kubernetes continuously monitors actual state and reconciles any difference automatically. This is called the **reconciliation loop**.

### Pod
- Smallest deployable unit in Kubernetes
- Wraps one or more containers
- Containers in the same Pod share network and storage
- Pods are not self-healing on their own

### Replicaset
- Ensure a specified number of Pod replicas are running at all times
- If a Pod dies, ReplicaSet creates a replacement automatically

### Deployment 
- Manages ReplicaSets
- Adds self-healing, scaling, rolling updates, and rollbacks
- Standard way to deploy applications in Kubernetes

### Service 
- Provides a stable IP and DNS name to access a set of Pods
- Solves two problems: Pod IPs change on recreation, multiple replicas need a single entry point 

#### Service Types
| Type | Accessibility |
|---|---|
| ClusterIP | Internal cluster only (default) |
| NodePort | External access via a static port on the node |
| LoadBalancer | External load balancer, used in cloud environments |

### NameSpace 
Logical partition within a cluster. Used to seperate environments or teams.

### ConfigMap / Secret
- ConfigMap - stores non-sensitive configuration data
- Secret - Stores sensitive data such as passwords and tokens 

---

## Tools 

| Tool | Purpose |
|---|---|
| kubectl | CLI to interact with the Kubernetes API |
| minikube | Runs a single-node Kubernetes cluster locally |

---

## Key Commands

```bash
# Start minikube
minikube start --driver=docker

# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Apply a manifest
kubectl apply -f <file>.yaml

# Get Pods
kubectl get Pods

# Describe a Pod
kubectl exec -it <pod-name> -- /bin/bash

# Delete a Pod
kubectl delete pod <pod-name>

# Get Deployments
kubectl get deployment

# Scale a Deployment 
kubectl scale deployment <name> --replicas=<number>

# Delete using manifest
kubectl delete -f <file>.yaml

# Get Services
kubectl get service

# Get minikube IP
minikube ip

# Stop minikube
minikube stop 
```

---

## Labs Completed

### Lab 1 - Deploying your first Pod
- Wrote a Pod manifest (pod.yaml)
- Applied it with `kubectl apply`
- Inspected with `kubectl get pods` and `kubectl describe`
- Executed into the Pod with `kubectl exec`
- Deleted with `kubectl delete`

### Lab 2 - Deployments and Scaling
- Created a Deployment with 3 replicas 
- Observed self-healing after manually deleting a Pod
- Scaled up to 5 replicas
- Scaled down to 2 replicas
- Deleted the Deployment

### Lab 3 - Services
- Created a NodePort Service 
- Connected it to the Deployment using lables and selectors
- Accessed nginx from outside the Pod via `curl http://192.168.49.2:30080`
- Cleaned up Deployment and Service 

---

## Environment USed

- Host: Kali Linux 
- VM: Ubuntu 24.04 on VirtualBox
- Cluster: minikube v1.38.1
- Kubernetes: v1.35.3
- kubectl: v1.35.3
- Driver: Docker 
