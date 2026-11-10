I have successfully created your first Kubernetes cluster and deployed your first Pod!

## 1. Your Kubernetes cluster is running

You executed:

```
kubectl get nodes
```

Output:

```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   35s   v1.37.0
```

What this means:

- `minikube`: Your Kubernetes node.
- `Ready`: The node is healthy and ready to run workloads.
- `control-plane`: It manages the Kubernetes cluster.
- `v1.37.0`: Your Kubernetes version.

Kubernetes cluster running

## 2. You created your first Pod

You executed:

```
kubectl create -f pod.yml
```

Output:

```
pod/nginx created
```

Then:

```
kubectl get pods
```

Output:

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          34s
```

This means:

- `nginx` is your Pod name.
- `1/1` means one container is ready out of one.
- `Running` means the Pod is running successfully.
- `0` restarts means the container hasn't restarted.

## 3. You verified the Nginx container

You executed:

```
kubectl get pods -o wide
```

Output:

```
NAME    READY   STATUS    IP
nginx   1/1     Running   10.244.0.3
```

Your Pod received the IP address `10.244.0.3`.

Then you entered the Minikube node:

```
minikube ssh
```

And tested:

```
curl 10.244.0.3
```

Successful response

You received:

```
<h1>Welcome to nginx!</h1>
```

This proves that your Nginx web server is running and responding to requests inside your Kubernetes cluster.

## 4. Understand what you have built

Here is the architecture of your current setup:

Your Windows Laptop

WSL Ubuntu + kubectl

Minikube Kubernetes Cluster

Node: Ready

Nginx Pod

IP: 10.244.0.3

Running

Container: Nginx Web Server

Welcome to nginx!

HTTP response received successfully

## 5. What should you learn next?

Now we will learn the next important Kubernetes concept: Service.

A Pod has its own IP address, but Pods can be recreated and their IP addresses can change. Kubernetes Services provide a stable way to access Pods.

Our next practical exercise will be:

1. Create a Kubernetes Service.
2. Connect the Service to your Nginx Pod.
3. Access Nginx through the Service.
4. Learn the difference between ClusterIP, NodePort and LoadBalancer.

First, exit the Minikube SSH session:

```
exit
```

You will return to your Ubuntu terminal.

Then execute:

```
kubectl expose pod nginx --type=NodePort --port=80
```

Check the Service:

```
kubectl get services
```

Then:

```
minikube service nginx --url
```

This will give you a URL to access your Nginx application.

<img width="1905" height="950" alt="Screenshot 2026-11-10 144506" src="https://github.com/user-attachments/assets/33257ecf-ea34-4b02-8268-ec0c68c971c5" />
<img width="1841" height="887" alt="Screenshot 2026-11-10 150005" src="https://github.com/user-attachments/assets/0a2723e7-a378-4233-b25e-84fc41662d19" />
<img width="1915" height="600" alt="Screenshot 2026-11-10 145425" src="https://github.com/user-attachments/assets/a1f04144-f41d-451f-9cbb-19ce39ba363c" />





