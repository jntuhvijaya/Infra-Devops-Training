## 1. What is Kubernetes?

Most important concept

Kubernetes (also called K8s) is an open-source container orchestration platform.

In simple words:

Kubernetes helps you deploy, manage, scale, and monitor applications running inside containers.

Imagine you developed a Python application using Flask or FastAPI.

You packaged your application into a Docker container. Now imagine your application has:

- 10 containers running.
- Thousands of users accessing it.
- Some containers crashing.
- Traffic increasing suddenly.
- Multiple application versions to manage.

Managing everything manually becomes difficult.

Kubernetes automates this management.

[Azure Kubernetes Service (AKS) for Beginners — From Zero to Deployment | by Kayode Yusuf | Medium](https://images.openai.com/static-rsc-4/dQgf8IeMuK5F_UOsyV_8Qttyv5zt7UmjxB5eqG518fAwUSIbP9LS-GhwNF9tEzWhI9T1M4gSAbNwTW8b8PnBScpGD3UQQggAG5TFv7Ue0kBj-0_8SGz543h4uIvICez71TSgWXkg-TIQxNiw47I6k7SgKzyMb3YGs87oJUhp2Ik?purpose=inline)

[medium.com](https://medium.com/%40yusufkayode4040/azure-kubernetes-service-aks-for-beginners-from-zero-to-deployment-6592353d8b4d?utm_source=chatgpt.com)

### Real-world example

Imagine an online shopping application like Amazon.

It has different services:

- User service
- Product service
- Payment service
- Order service
- Delivery service

Each service may run in multiple containers.

Kubernetes manages these containers and helps ensure that the application remains available even when some containers fail.

## 2. Why do we need Kubernetes?

Without Kubernetes, developers may need to manually:

- Start and stop containers.
- Restart crashed containers.
- Increase or decrease container instances.
- Distribute incoming traffic.
- Manage application deployments.
- Handle application failures.

Kubernetes helps automate these activities.

| Feature            | What Kubernetes does                             |
| ------------------ | ------------------------------------------------ |
| Self-healing       | Restarts failed containers                       |
| Auto-scaling       | Increases or decreases application instances     |
| Load balancing     | Distributes traffic                              |
| Rolling updates    | Updates applications without stopping everything |
| Rollbacks          | Returns to an earlier application version        |
| Service discovery  | Helps services find each other                   |
| Storage management | Connects persistent storage to applications      |

## 3. Docker vs Kubernetes

This is one of the most important interview questions.

[5 things you should know about Docker | TechRadar](https://images.openai.com/static-rsc-4/z1CShiGpLAYCWzS-f__l5RSJD6ZTdFUX8fiHe1cIM0f3mPlM7q-woMdd6ignKyjqW4mopRvrL_WQxv19NGsOyfwcI-xsFOupKibp_uHZzjDIiZVUwT3ploj4GGQT6IA5g2UeeRGWK-swwIlEIfBUT01Fsn5526qP7iym6d1o_Ew?purpose=inline)

Docker

Used to build, package and run containers.

[DevOps, Continuous Delivery... and You - Full Stack Python](https://images.openai.com/static-rsc-4/zVPRXH7i89DWyRHJSK01J9I4pV7GUi0RF_go3gRNhC30nxAOVPkZBY7JEycXEpHwiEQmcypgZmorm62_-uRdTGc4uKqeP_zP018BiKcf9je4ooH6OjsuVWOnYvPY9wv7Y5rS1aMwHS4Wczhe90dEaip9yTQH4ApWt4wdBI1GM_g?purpose=inline)

Kubernetes

Used to manage and orchestrate containers across machines.

| Docker                   | Kubernetes                                 |
| ------------------------ | ------------------------------------------ |
| Builds container images  | Deploys and manages applications           |
| Runs containers          | Manages containers through Pods            |
| Mainly container tooling | Container orchestration                    |
| Can run standalone       | Usually manages workloads across a cluster |

Easy way to remember:

- Docker = Creates and runs the packaged application.
- Kubernetes = Manages the application at scale.

Kubernetes doesn't replace Docker as a container image-building tool. It can use images built with Docker, but modern Kubernetes commonly uses container runtimes such as containerd.

## 4. Kubernetes architecture

This is the foundation of Kubernetes.

A Kubernetes environment is called a Cluster.

A cluster has two major parts:

1. Control Plane
2. Worker Nodes

[Medium](https://images.openai.com/static-rsc-4/wXnoP9BLBDSYsfDdMIyZxLYfpmG5S1DPiQlyr3zY36fwS1MUQmcaUSwtrgACJVmAv9Dn3tnbY3JD_7C21nsXvtHmgg_Iamc__2uZ9Typufm-x2KwxCAfgEWqXVrwAqCAkVPj1mX-21W9F4e3X-sjv5sMV-NdcgXWCy4G-8x_J1A?purpose=inline)

[medium.com](https://medium.com/%40Venkata-Reddy-DevOps/kubernetes-k8s-architecture-2553031418e7?utm_source=chatgpt.com)

### A. Control Plane

The Control Plane manages the entire Kubernetes cluster.

Think of it as the brain of Kubernetes.

It contains these important components:

| Component                | Responsibility                                  |
| ------------------------ | ----------------------------------------------- |
| API Server               | Entry point for Kubernetes requests             |
| etcd                     | Stores cluster configuration and state          |
| Scheduler                | Decides which worker node should run a Pod      |
| Controller Manager       | Ensures actual state matches desired state      |
| Cloud Controller Manager | Integrates Kubernetes with cloud infrastructure |

Let's understand each:

1\. API Server

- Main communication point of Kubernetes.
- Receives commands from users and other components.
- Example: `kubectl get pods`.

2\. etcd

- A key-value database.
- Stores Kubernetes cluster information.
- Keeps configuration and state information.

3\. Scheduler

- Selects an appropriate worker node for newly created Pods.
- Considers available resources and scheduling requirements.

4\. Controller Manager

- Continuously checks the cluster.
- Ensures the desired number of Pods are running.

5\. Cloud Controller Manager

\- Helps Kubernetes communicate with cloud providers such as AWS, Azure and Google Cloud.

### B. Worker Nodes

Worker nodes are machines where your applications actually run.

They can be physical servers or virtual machines such as AWS EC2 instances.

Each worker node generally has:

| Component         | Responsibility                                                   |
| ----------------- | ---------------------------------------------------------------- |
| Kubelet           | Communicates with the Control Plane and manages Pods on the node |
| Container Runtime | Runs containers                                                  |
| Kube-proxy        | Implements network service rules, where deployed                 |

Remember:

- Control Plane = Brain.
- Worker Node = Machine that runs applications.

## 5. Important Kubernetes concepts

You should understand these terms before working with Kubernetes.

[INTRO Kubernetes – Exoscale Documentation](https://images.openai.com/static-rsc-4/MjmDp8Np6hwYfUUyHiCKJc98x8siIEiHFLu-1Feox5jNHBdheKJ-YlzmJmnomlt-i3K8HV2vmBWPlRgwqly9ZsA_MnwKRa2EAKWdXzNiiKYx3aFd7ZIzXlH2B6jwGebgBG6t5M4790vGDCA6qM-rOOLXEmNFzYsnJC58wWz8zqM?purpose=inline)

1\. Pod

The smallest deployable unit in Kubernetes.

A Pod contains one or more containers. Usually, one application container runs in one Pod.

[Kubernetes ReplicaSets and Deployments | Coding Shuttle](https://images.openai.com/static-rsc-4/DILhvOVMlIVZHXbOtR1OGTjQyWGFD1LbxVcJlTycKT9w_NCAqp_XThe0YPphX8THI126jw2dlFE98fXsOzxzfk9K6EZy0pCstZ11D3oxnXs1aUgGaIUn3bWKgE-prpe5cd62mS1YXf5OMCyko9COY_0ryvzX3TS7WZfhMtx7AZY?purpose=inline)

2\. Deployment

Manages the desired number of Pod replicas and supports rolling updates and rollbacks.

Example: You want three copies of your application running. A Deployment manages those three replicas.

[Getting started with Kubernetes Services - Spectro Cloud](https://images.openai.com/static-rsc-4/9q9PtIuPLnk1AGFr44cGg-Bfrv81EHwAE-WwlzN4IoCx2KdCwM9dQR4nym4dqzkzXT8y_vPB_mtkfUwJCpLqMvnMxpGD_Ah0TpmXVnZqbfD8HZ_BU7wFM3xBEHG2lhDemr8E0lqcZ2MLIbmGHSHp-TDPpsDzbKLIVYRrBp8gTkI?purpose=inline)

3\. Service

Provides a stable network endpoint to access a group of Pods.

Even if Pods are recreated and their IP addresses change, the Service provides a stable way to reach them.

[Kubernetes Ingress Controllers Explained: NGINX vs Traefik vs HAProxy (2025 Edition) | by agdias channel | Medium](https://images.openai.com/static-rsc-4/HEq5QdxOFm-ocMlHqQFYysz4J-K19idFQDv626jp9VgWoIq5HbvpElECEiomfWYAUFMWudJ6BoukvOoSeC3SsKolKQzrpj4SWSxwWgR-fPrMX4e-C46M-2uZd_3fV-7D-vnv05m3vI_Y-xradvxKisFc9DtX07YzgEf0PcQJZdc?purpose=inline)

4\. Ingress

Manages external HTTP/HTTPS access to applications inside a cluster, using an Ingress controller.

[Configuration and Secret Management for Real Environments : Course Kubernetes for Developers: Deploy, Scale, and Operate Modern Apps with Helm, GitOps, and Observability | Cursa](https://images.openai.com/static-rsc-4/d4TUyIWashTlq8kSMK-VFOWVRx9Nm3SuAEU4MdvGMYky790IF1e7o2aGlLONs360_90KOTjwoLwwiaQAIjx-UD4g2D0ydh8l9Qt0RLDnIpzA34qZ1N-66zm7eJUj8EDuzKmiylredwzLbxU9PeWCqPhy6AJ2omcpIJogSJ37yZ8?purpose=inline)

5\. ConfigMap and Secret

- ConfigMap: Stores non-sensitive configuration.
- Secret: Stores sensitive configuration such as passwords and tokens.

Secrets need appropriate access controls and encryption; they are not automatically secure just because they are called Secrets.

[Day 45: Persistent Storage in Kubernetes — Volumes and PV/PVC | by Karthick Dk | devsecops-community | Medium](https://images.openai.com/static-rsc-4/uLsbVZWWLZh4jYznxS161elkdiv43QSAffPPi6n8pSMPmu7tVlSKAIap90JPE1QSwEmAZw79KzTUMwuPk20-BmeQAfHFsui9h5GDfK4Rodrcbsx-8OeAcj0A7zOcXh7dXwd8a28CTZ_VbFnC5l2MML2_kIzrNIVMsYVT8aRq32E?purpose=inline)

6\. Persistent Volume (PV) and Persistent Volume Claim (PVC)

Used to provide persistent storage to applications.

- PV: Storage resource.
- PVC: A request for storage by an application.

[Manage scale-to-zero scenarios with Karpenter and Serverless | Containers](https://images.openai.com/static-rsc-4/P2z8pMgZGQhNGvYB3_uZvTPR3zgxb6IV2byhDigzptlf9pu5pejT5LFq2z7muro6I2V5T17Xx05TJoVtq5EXlpOHwwnUCglPF-ewYIEPKYj0jJSNrU31upzaY_sR8Fy-GMn7F3arPxL7uB0PB8Jfz0Nvd_JeaQuODXJvCuZPMVs?purpose=inline)

7\. HPA (Horizontal Pod Autoscaler)

Automatically increases or decreases the number of Pod replicas based on metrics such as CPU or memory utilization.

### Other important terms

| Term            | Meaning                                                      |
| --------------- | ------------------------------------------------------------ |
| Namespace       | Separates resources into logical groups                      |
| ReplicaSet      | Maintains a specified number of Pod replicas                 |
| StatefulSet     | Manages applications that need stable identities and storage |
| DaemonSet       | Runs a Pod on each eligible node                             |
| Job             | Runs a task until it completes                               |
| CronJob         | Runs scheduled tasks                                         |
| Liveness Probe  | Checks whether a container should be restarted               |
| Readiness Probe | Checks whether a Pod is ready to receive traffic             |
| Node            | A machine in the cluster                                     |
| Cluster         | A group of nodes managed by Kubernetes                       |

## 6. How Kubernetes works – step by step

Let's assume you have a Python FastAPI application.

You want to deploy it using Kubernetes.

[Demystifying Kubernetes Deployments: From YAML to Running Pods | by Sidharath Bansal | Medium](https://images.openai.com/static-rsc-4/mOZqotPTfSCBuLVDFpUBF_4sWLnPZdTJXUyXlJKLdlZn8efqv5s4E22JJ9WRH-uyVnxRWUxT_yDeKG8wi1opeDXCwxtRpdOOcwVWIEQMQUkNk2JzjGAK-vZR-qQ4YC4mlQCKMGlpC2y4xf2Awf-O2gwjKQUr-dQaxE7cKe99uaU?purpose=inline)

[sidharathbansal.medium.com](https://sidharathbansal.medium.com/demystifying-kubernetes-deployments-from-yaml-to-running-pods-7a85e232a457?utm_source=chatgpt.com)

The workflow is:

1. Develop your application using Python.
2. Create a Dockerfile.
3. Build a Docker image.
4. Push the image to a container registry (Docker Hub or Amazon ECR).
5. Create Kubernetes YAML configuration files.
6. Apply the YAML files using `kubectl`.
7. Kubernetes receives your request through the API Server.
8. The Scheduler selects a suitable worker node.
9. Kubelet starts the Pod using the container runtime.
10. A Service exposes your application to other services or users.

Example:

You tell Kubernetes:

"I want three copies of my FastAPI application running."

Kubernetes tries to maintain three replicas.

If one Pod crashes, Kubernetes works to replace it.

If you increase the desired replicas to five, Kubernetes tries to run five.

This is called desired state management.

## 7. Kubernetes YAML files

Kubernetes uses YAML configuration files to define resources.

For example, a Deployment file:

```

apiVersion: apps/v1
kind: Deployment

metadata:
  name: my-python-app

spec:
  replicas: 3

  selector:
    matchLabels:
      app: my-python-app

  template:
    metadata:
      labels:
        app: my-python-app

    spec:
      containers:
        - name: python-container
          image: nginx:latest
          ports:
            - containerPort: 80

```

Let's understand the important fields:

| Field         | Meaning                                   |
| ------------- | ----------------------------------------- |
| apiVersion    | Kubernetes API version                    |
| kind          | Resource type                             |
| metadata      | Resource name and labels                  |
| spec          | Desired configuration                     |
| replicas      | Number of desired Pods                    |
| selector      | Identifies Pods managed by the Deployment |
| template      | Defines how Pods should be created        |
| containers    | Container configuration                   |
| image         | Container image to run                    |
| containerPort | Port used by the container                |

This example uses Nginx as a simple demonstration. Later, you can replace it with your own FastAPI Docker image.

### Service YAML

Now let's expose those Pods using a Service.

```

apiVersion: v1
kind: Service

metadata:
  name: my-python-service

spec:
  type: NodePort

  selector:
    app: my-python-app

  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080

```

Here:

- `type: NodePort` exposes the service on a port of each eligible node.
- `port` is the Service port.
- `targetPort` is the container port.
- `nodePort` is the externally exposed node port.

## 8. Kubernetes commands you must know

The command-line tool used to communicate with Kubernetes is called kubectl (Kubernetes control).

These are some essential commands:

| Command                                               | Purpose                            |
| ----------------------------------------------------- | ---------------------------------- |
| `kubectl version`                                     | Check client/server versions       |
| `kubectl get nodes`                                   | List worker nodes                  |
| `kubectl get pods`                                    | List Pods                          |
| `kubectl get deployments`                             | List Deployments                   |
| `kubectl get services`                                | List Services                      |
| `kubectl describe pod POD_NAME`                       | View Pod details and events        |
| `kubectl logs POD_NAME`                               | View container logs                |
| `kubectl apply -f deployment.yaml`                    | Create or update resources         |
| `kubectl delete -f deployment.yaml`                   | Delete resources defined in a file |
| `kubectl scale deployment my-python-app --replicas=5` | Scale to five replicas             |
| `kubectl exec -it POD_NAME -- /bin/sh`                | Open a shell inside a container    |
| `kubectl get pods -A`                                 | List Pods across all namespaces    |

One particularly useful command:

```
kubectl get pods -o wide
```

It shows Pod status, IP address and the node on which each Pod is running.

Common Pod statuses:

- `Running` – Pod is running.
- `Pending` – Waiting for scheduling or resources.
- `CrashLoopBackOff` – Container repeatedly crashes.
- `ImagePullBackOff` – Kubernetes cannot pull the container image.
- `Completed` – Container finished successfully.

## 9. Different types of Kubernetes environments

You can learn Kubernetes on your laptop or deploy it in the cloud.

| Tool / Platform  | Purpose                                               |
| ---------------- | ----------------------------------------------------- |
| Minikube         | Runs a local Kubernetes cluster, usually for learning |
| Kind             | Runs Kubernetes clusters using Docker containers      |
| Kubernetes (K8s) | The orchestration platform itself                     |
| Amazon EKS       | AWS-managed Kubernetes service                        |
| Azure AKS        | Azure-managed Kubernetes service                      |
| Google GKE       | Google-managed Kubernetes service                     |
| kubeadm          | Tool to create and manage Kubernetes clusters         |

[\[Kubernetes\] Minikube 설치](https://images.openai.com/static-rsc-4/KCPXqZXqNL0dq7U910Mgzt59ybIxb7oanA2-RxlYCm53liSg-hMhTHhkw-HHorKDpiL1PGqS4m18DGODwj8_7AYFHZUjqRpb4nfGWMTn_awInarq0dtuw7-Wb8VSIYHAEyZYErRxgVlmWbs4p--l_vEAZaPt0fhoRdXTyIAS4rk?purpose=inline)

Minikube

Best for beginners learning Kubernetes locally.

[Free High-Quality Amazon EKS Logo for Creative Design](https://images.openai.com/static-rsc-4/Or04aWW_S6Y8QP12Tpysowjs5H9xNIfIoUsmXmvXwhfdlDyIWS0alY3VTsThAXaJg4qtUdzLyz94i6YfXPubs3qOLgJhm-TK30A0cOWV6iHv3QfWUkel7f0UY90cm-3f1HjL8goBOgC4_6of--688sUXF4gstLAhGxNnzVWd7Tk?purpose=inline)

Amazon EKS

Runs Kubernetes clusters on AWS. AWS manages the Kubernetes control plane.

kubectl

The command-line tool used to interact with Kubernetes clusters.

### 10. How Kubernetes connects with AWS, Docker and Terraform

Since you're learning AWS and Terraform, understand this relationship:

[How Amazon EKS Auto Mode Simplifies Kubernetes Management | Abhishek Veeramalla posted on the topic | LinkedIn](https://images.openai.com/static-rsc-4/l_XrkNB7cwuQnQqMwN4mxud2j-nRRZ4gFRlvQGv6EtIuie1JROsuhLGsP6m6eHNmZNYP0NLYgkYGp_KkkYQ9HUDootJ-etX043oqbUWafM7r8UyMWl0ix1BxqhZ5d2dKCwbhVaFQ5l6R083HOcBjxiBknql3UFMxpmQOpzbNLyo?purpose=inline)

[linkedin.com](https://www.linkedin.com/posts/abhishek-veeramalla_sponsored-aws-eksautomode-activity-7365746297338806272-wfZV?utm_source=chatgpt.com)

| Technology | What it does                            |
| ---------- | --------------------------------------- |
| AWS        | Provides cloud infrastructure           |
| EC2        | Provides virtual machines               |
| Docker     | Builds container images                 |
| Amazon ECR | Stores container images                 |
| Kubernetes | Orchestrates containerized applications |
| Amazon EKS | Provides managed Kubernetes             |
| Terraform  | Creates infrastructure using code       |
| kubectl    | Communicates with Kubernetes            |

Example real-world workflow:

1. Use Terraform to create AWS infrastructure.
2. Create an EKS cluster.
3. Build a Docker image for your Python application.
4. Push the image to Amazon ECR.
5. Deploy the image to Kubernetes using YAML.
6. Expose the application using a Kubernetes Service or Ingress.
7. Monitor and scale your application.

This is a common DevOps workflow.

## 11. Kubernetes vs Docker Compose

You might also hear about Docker Compose.

| Docker Compose                    | Kubernetes                                 |
| --------------------------------- | ------------------------------------------ |
| Runs multiple containers together | Orchestrates applications across a cluster |
| Simple local development          | Local and production deployments           |
| Basic restart policies            | Advanced self-healing                      |
| Basic scaling                     | Advanced scaling and scheduling            |
| Simpler configuration             | More comprehensive configuration           |

For a beginner, Docker Compose is often easier to start with. Kubernetes is useful when you need more advanced orchestration.

## 12. Advantages and disadvantages

Advantages

- Automated application deployment.
- Self-healing capabilities.
- High availability when configured across suitable infrastructure.
- Application scaling.
- Rolling updates and rollbacks.
- Service discovery and load balancing.
- Portability across supported environments.

Disadvantages

- More complex to learn.
- Requires monitoring and maintenance.
- Can increase infrastructure costs.
- Requires knowledge of networking and security.
- Can be unnecessary for small applications.

