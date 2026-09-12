# Flask Email Tool – Podman Containerization

## 1. Application Testing

We first ran the Flask email application locally using Python virtual environment (`myenv`).

The application was tested through the browser/API.

Successful requests:

```text
GET / HTTP/1.1 → 200
POST /send-email HTTP/1.1 → 200
```

`200` means the request was successfully processed.

---

## 2. Podman Setup

When we tried to build the container:

```powershell
podman build -t test_emailtool .
```

we initially received:

```text
Cannot connect to Podman
```

This happened because the Podman Linux machine was not running.

We checked the Podman connections:

```powershell
podman system connection list
```

Then started the Podman machine:

```powershell
podman machine start
```

Podman reported:

```text
Machine "podman-machine-default" started successfully
```

To verify Podman:

```powershell
podman info
```

---

## 3. Building the Container Image

From the project directory:

```powershell
cd C:\Users\Vi39060Po\Projects\email_tool
```

we built the image:

```powershell
podman build -t test_emailtool .
```

### What this command means

* `podman build` → Builds a container image
* `-t test_emailtool` → Gives the image the name `test_emailtool`
* `.` → Uses the current directory as the build context

The build completed successfully:

```text
Successfully tagged localhost/test_emailtool:latest
```

So we created the image:

```text
localhost/test_emailtool:latest
```

---

## 4. Understanding the Build Steps

The Containerfile/Dockerfile contained steps such as:

```dockerfile
COPY . ./
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

### COPY

<img width="1507" height="882" alt="image" src="https://github.com/user-attachments/assets/61d12629-218e-485e-a28c-55b1f39dcbca" />

```dockerfile
COPY . ./
```

Copies the application files from the local project directory into the container image.

If the project contains unnecessary folders such as:

```text
myenv/
.git/
__pycache__/
```

the `COPY` step can take longer.

To avoid copying unnecessary files, create:

```text
.dockerignore
```

Example:

```text
myenv/
venv/
.env
__pycache__/
*.pyc
.git/
.vscode/
```

---

```text
gunicorn
```

to `requirements.txt`.

Then rebuilt the image:

```powershell
podman build -t test_emailtool .
```

The image was successfully rebuilt.

---

## 6. Image vs Container

This is an important concept.

### Image

An image is the packaged application/template.

Example:

```text
test_emailtool
```

### Container

A container is a running/created instance of an image.

Example:

```text
emailtool
```

Relationship:

```text
Dockerfile / Containerfile
        ↓
     IMAGE
 test_emailtool
        ↓
   podman run
        ↓
   CONTAINER
     emailtool
```

---

## 7. Checking Images

To see available images:

```powershell
podman images
```

Example:

```text
localhost/test_emailtool:latest
```

---

## 8. Checking Containers

To see currently running containers:

```powershell
podman ps
```

To see all containers, including stopped/failed containers:

```powershell
podman ps -a
```

We found a container with an automatically generated name:

```text
determined_cohen
```

This happened because a container had been created without successfully starting.

We can remove it using:

```powershell
podman rm determined_cohen
```

---

## 9. Running the Email Tool

To create and run the container:

```powershell
podman run -d -p 5000:5000 --name emailtool test_emailtool
```

### Meaning

```text
-d
```

Runs the container in detached/background mode.

```text
-p 5000:5000
```

Maps:

```text
Host port 5000 → Container port 5000
```

```text
--name emailtool
```

Gives the container the name `emailtool`.

```text
test_emailtool
```

Specifies the image to use.

---

## 10. Accessing the Application

After the container is running:

```text
http://localhost:5000
```

can be opened in the browser.

---

## 11. Container Logs

If the application does not work, check the logs:

```powershell
podman logs emailtool
```

This is useful for identifying application or Gunicorn startup errors.

---

## 12. Stopping and Starting

### Stop the container

```powershell
podman stop emailtool
```

### Start the existing container again

```powershell
podman start emailtool
```

We do NOT need to run `podman run` again if the container already exists.

`podman run` creates a new container.

`podman start` starts an existing stopped container.

---

## 13. Podman Machine

When finished with Podman, the Podman machine can be stopped:

```powershell
podman machine stop
```

Later, start it again with:

```powershell
podman machine start
```

We only use:

```powershell
podman machine init
```

when creating a Podman machine for the first time. We don't need to initialize it every time.

---

# Important Commands Learned

```powershell
# Start Podman machine
podman machine start

# Stop Podman machine
podman machine stop

# Check Podman
podman info

# Build image
podman build -t test_emailtool .

# List images
podman images

# List running containers
podman ps

# List all containers
podman ps -a

# Run container
podman run -d -p 5000:5000 --name emailtool test_emailtool

# Stop container
podman stop emailtool

# Start existing container
podman start emailtool

# Remove container
podman rm emailtool

# View container logs
podman logs emailtool
```

# Overall Flow

```text
Python Flask Application
        ↓
Test locally
        ↓
Create requirements.txt
        ↓
Create Dockerfile/Containerfile
        ↓
Start Podman machine
        ↓
podman build
        ↓
Container Image
test_emailtool
        ↓
podman run
        ↓
Container
emailtool
        ↓
Port 5000
        ↓
http://localhost:5000
        ↓
Flask Email Application
```

## Key DevOps Concepts Learned

1. **Container Image** – packaged application and its dependencies.
2. **Container** – running instance of an image.
3. **Dockerfile/Containerfile** – instructions used to build an image.
4. **Podman** – container engine used to build and run containers.
5. **Port Mapping** – connects a host port to a container port.
6. **Gunicorn** – production WSGI server used to run the Flask application.
7. **`.dockerignore`** – prevents unnecessary files from being copied into the image.
8. **Container Logs** – used to troubleshoot application/container issues.
9. **Podman Machine** – Linux environment used by Podman on Windows.
10. **`podman build` vs `podman run`** – build creates the image; run creates and starts a container from that image.
<img width="1558" height="697" alt="image" src="https://github.com/user-attachments/assets/f7cecf3f-3d10-4ef9-941e-e14ca00d6f15" />
<img width="1562" height="837" alt="image" src="https://github.com/user-attachments/assets/b7d87f0b-3b60-4e9b-a96b-ca540a750960" />


