I have successfully created my first Kubernetes cluster and deployed my first Pod!

## 1. Kubernetes cluster is running

executed:

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

## 2. created the first Pod

executed:

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

## 3. verified the Nginx container

executed:

```
kubectl get pods -o wide
```

Output:

```
NAME    READY   STATUS    IP
nginx   1/1     Running   10.244.0.3
```

Pod received the IP address `10.244.0.3`.

Then entered the Minikube node:

```
minikube ssh
```

And tested:

```
curl 10.244.0.3
```

Successful response

received:

```
<h1>Welcome to nginx!</h1>
```

This proves that Nginx web server is running and responding to requests inside the Kubernetes cluster.

## 4. Understand what I have built

Here is the architecture of the current setup:

Windows Laptop

WSL Ubuntu + kubectl

Minikube Kubernetes Cluster

Node: Ready

Nginx Pod

IP: 10.244.0.3

Running

Container: Nginx Web Server

Welcome to nginx!

HTTP response received successfully

First, exit the Minikube SSH session:

```
exit
```

 will return to your Ubuntu terminal.

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
<img width="1795" height="976" alt="image" src="https://github.com/user-attachments/assets/7e07e1ad-a706-464b-b29c-0cb4cc3f7431" />
<img width="1915" height="600" alt="Screenshot 2026-11-10 145425" src="https://github.com/user-attachments/assets/a1f04144-f41d-451f-9cbb-19ce39ba363c" />





