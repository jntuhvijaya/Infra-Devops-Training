# AWS CI/CD Learning Notes – Python Flask Application

This document records the complete CI/CD implementation we did for a simple Python Flask application using **GitHub + AWS CodePipeline + CodeBuild + Amazon EC2 + Systems Manager (SSM)**.

The goal was to understand a real CI/CD pipeline **without Docker** first.

---

# 1. Objective

We wanted to build this flow:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   ▼
AWS CodePipeline
   │
   ├── Source
   │
   ▼
AWS CodeBuild
   │
   │ Build + Validate + Create artifact
   ▼
Amazon EC2 Deploy Action
   │
   ▼
AWS Systems Manager (SSM)
   │
   ▼
EC2 Ubuntu Server
   │
   ▼
systemd
   │
   ▼
Gunicorn
   │
   ▼
Flask Application
```

The important concept is:

> **A developer pushes code to GitHub, and AWS automatically builds and deploys the application to EC2.**

AWS's EC2 deploy action supports Linux EC2 instances that are managed through Systems Manager/SSM Agent. ([AWS Documentation][1])

---

# 2. Application Used

We created a very simple Flask application.

### `app.py`

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, world!'

if __name__ == '__main__':
    app.run()
```

The application has one endpoint:

```text
/
```

and returns:

```text
Hello, world!
```

---

# 3. Project Structure

Our final GitHub repository structure is:

```text
simple-python-app/
│
├── app.py
├── requirements.txt
├── Procfile
├── buildspec.yml
├── deployspec.yml
├── README.md
│
└── scripts/
    ├── stop_app.sh
    └── start_app.sh
```

### Purpose of each file

| File               | Purpose                              |
| ------------------ | ------------------------------------ |
| `app.py`           | Flask application                    |
| `requirements.txt` | Python dependencies                  |
| `Procfile`         | Defines Gunicorn application command |
| `buildspec.yml`    | Instructions for CodeBuild           |
| `deployspec.yml`   | Instructions for EC2 deployment      |
| `start_app.sh`     | Starts/configures application        |
| `stop_app.sh`      | Stops existing application           |
| `README.md`        | Documentation                        |

---

# 4. `requirements.txt`

```text
Flask
gunicorn
```

We need:

* **Flask** → web framework
* **Gunicorn** → production WSGI server

---

# 5. Procfile

```text
web: gunicorn --bind :8000 app:app
```

This means:

```text
gunicorn
   ↓
app.py
   ↓
Flask object named "app"
```

The application listens on port:

```text
8000
```

---

# 6. AWS CodeBuild

## What is CodeBuild?

**AWS CodeBuild** is the build service.

It runs commands such as:

```text
install dependencies
run validation
run tests
compile/package application
create build artifact
```

AWS CodeBuild uses a **buildspec** file to define these commands. ([AWS Documentation][2])

---

# 7. `buildspec.yml`

We used:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.12

  pre_build:
    commands:
      - echo "Installing dependencies..."
      - pip install -r requirements.txt

  build:
    commands:
      - echo "Running application validation..."
      - python --version
      - python -m py_compile app.py

  post_build:
    commands:
      - echo "Build completed successfully!"

artifacts:
  files:
    - '**/*'
```

## Explanation

### Version

```yaml
version: 0.2
```

Defines the CodeBuild buildspec version.

### Install phase

```yaml
install:
  runtime-versions:
    python: 3.12
```

CodeBuild prepares Python 3.12.

### Pre-build

```yaml
pip install -r requirements.txt
```

Installs:

```text
Flask
Gunicorn
```

### Build

```bash
python --version
```

Checks Python.

Then:

```bash
python -m py_compile app.py
```

checks that the Python source can be compiled successfully.

### Post-build

Prints a successful completion message.

### Artifacts

```yaml
artifacts:
  files:
    - '**/*'
```

This tells CodeBuild to include all files recursively in the build output.

AWS documents `**/*` as a pattern that includes files recursively. ([AWS Documentation][2])

---

# 8. CodeBuild Project

We created:

```text
Project:
simple-python-app-build
```

### Source

GitHub:

```text
https://github.com/jntuhvijaya/simple-python-app
```

Branch:

```text
master
```

### Environment

We configured:

```text
Managed image
EC2
Ubuntu
Standard
aws/codebuild/standard:8.0
2 vCPU
4 GiB
Python 3.12
```

Privileged mode:

```text
OFF
```

This was intentional because we were **not using Docker**.

---

# 9. CodeBuild Testing

Before connecting CodeBuild to CodePipeline, we manually ran a CodeBuild build.

The build successfully completed:

```text
Source download       SUCCESS
Install                SUCCESS
Pre-build              SUCCESS
Build                  SUCCESS
Post-build             SUCCESS
Artifacts              SUCCESS
```

The important validation was:

```text
python -m py_compile app.py
```

which succeeded.

---

# 10. Amazon EC2

We created an Ubuntu EC2 instance.

Important configuration:

```text
AMI: Ubuntu
Instance type: t3.micro
```

We gave the instance the name:

```text
simple-python-app-server
```

This tag became important later because CodePipeline uses the tag to find the deployment target.

### EC2 tag

```text
Name = simple-python-app-server
```

---

# 11. EC2 IAM Role

We created an EC2 instance role:

```text
CodeDeploy-EC2-Instance-Role
```

The instance was given permissions needed for Systems Manager.

The SSM Agent on an EC2 instance uses permissions supplied through the EC2 instance profile/role. ([AWS Documentation][3])

---

# 12. AWS Systems Manager / SSM

Instead of using CodeDeploy, we used the **Amazon EC2 Deploy action in CodePipeline with SSM**.

This was important because our CodeDeploy console setup was blocked by the account setup issue.

The architecture became:

```text
CodePipeline
      ↓
EC2 Deploy Action
      ↓
SSM
      ↓
EC2
```

AWS's current documentation confirms that the EC2 deploy action can deploy to Linux EC2 instances that are SSM-managed and requires the SSM Agent. ([AWS Documentation][1])

---

# 13. Verify SSM Agent

Initially we checked:

```bash
sudo systemctl status amazon-ssm-agent
```

The Ubuntu installation used Snap.

We found that SSM Agent was already installed and then verified:

```bash
sudo snap list amazon-ssm-agent
```

and:

```bash
sudo snap services amazon-ssm-agent
```

The service was active.

In Systems Manager → Managed Nodes, our EC2 instance appeared as:

```text
Running
Ping: Online
Agent: 3.3.4121.0
```

This confirmed:

```text
EC2
 ↓
SSM Agent
 ↓
AWS Systems Manager
```

was working.

---

# 14. Deployment Files

We created a deployment specification:

```text
deployspec.yml
```

Important: **the filename is `.yml`, not `.yaml`.**

This caused one of our deployment failures later.

---

# 15. `deployspec.yml`

```yaml
version: 0.1

files:
  - source: /
    destination: /home/ubuntu/simple-python-app/

scripts:
  BeforeDeploy:
    - location: scripts/stop_app.sh
      timeout: 300
      runas: root

  AfterDeploy:
    - location: scripts/start_app.sh
      timeout: 600
      runas: root
```

## What does this do?

### Files section

```yaml
source: /
```

Means take the deployment artifact.

```yaml
destination: /home/ubuntu/simple-python-app/
```

Copy the application to:

```text
/home/ubuntu/simple-python-app/
```

### BeforeDeploy

Runs:

```text
scripts/stop_app.sh
```

before the new application is deployed.

### AfterDeploy

Runs:

```text
scripts/start_app.sh
```

after the files have been deployed.

---

# 16. `stop_app.sh`

```bash
#!/bin/bash

echo "Stopping Flask application..."

systemctl stop simple-python-app.service || true

echo "Application stopped."
```

This stops the currently running application.

The:

```bash
|| true
```

means that if the service does not exist yet, the deployment should continue instead of failing.

---

# 17. `start_app.sh`

The script performs several tasks.

```bash
#!/bin/bash

set -e

APP_DIR="/home/ubuntu/simple-python-app"
VENV_DIR="$APP_DIR/venv"
SERVICE_FILE="/etc/systemd/system/simple-python-app.service"
```

### Step 1 — Change ownership

```bash
chown -R ubuntu:ubuntu "$APP_DIR"
```

Makes the `ubuntu` user the owner.

### Step 2 — Install virtual environment support

```bash
apt-get update
apt-get install -y python3-venv
```

### Step 3 — Create virtual environment

```bash
python3 -m venv "$VENV_DIR"
```

### Step 4 — Install dependencies

```bash
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt"
```

This installs Flask and Gunicorn.

### Step 5 — Create systemd service

We created:

```text
/etc/systemd/system/simple-python-app.service
```

with:

```ini
[Unit]
Description=Simple Python Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/simple-python-app
ExecStart=/home/ubuntu/simple-python-app/venv/bin/gunicorn --bind 0.0.0.0:8000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

This makes Gunicorn run as a Linux service.

### Step 6 — Reload systemd

```bash
systemctl daemon-reload
```

### Step 7 — Enable service

```bash
systemctl enable simple-python-app.service
```

This allows the service to start automatically when the system boots.

### Step 8 — Start application

```bash
systemctl restart simple-python-app.service
```

---

# 18. CodePipeline

We created:

```text
simple-python-app-pipeline
```

Pipeline type:

```text
V2
```

Execution mode:

```text
QUEUED
```

---

# 19. Source Stage

Source provider:

```text
GitHub via GitHub App
```

Repository:

```text
jntuhvijaya/simple-python-app
```

Branch:

```text
master
```

Change detection:

```text
Enabled
```

So when code is pushed to `master`, CodePipeline can detect the change and start the pipeline.

---

# 20. Build Stage

Build provider:

```text
AWS CodeBuild
```

Project:

```text
simple-python-app-build
```

Input:

```text
SourceArtifact
```

Output:

```text
BuildArtifact
```

The CodeBuild action receives the source artifact and can make its output available to later CodePipeline actions. ([AWS Documentation][4])

---

# 21. Deploy Stage

Provider:

```text
Amazon EC2
```

Region:

```text
us-east-1
```

Instance type:

```text
EC2
```

Target tag:

```text
Key:   Name
Value: simple-python-app-server
```

Therefore CodePipeline searches for:

```text
Name = simple-python-app-server
```

and found our instance:

```text
i-0a1b9f16bf7ce90c
```

The EC2 deploy action supports targeting Linux EC2 instances and uses SSM to execute deployment commands. ([AWS Documentation][1])

---

# 22. First Pipeline Failure – IAM Permission

Our first deployment failed with:

```text
AccessDeniedException
```

Specifically:

```text
logs:PutLogEvents
```

The CodePipeline service role did not have the required CloudWatch Logs permission.

---

# 23. Finding the Correct IAM Role

The CodePipeline service role was:

```text
AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

Its ARN was:

```text
arn:aws:iam::853617422750:role/service-role/AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

We opened that role from:

```text
CodePipeline
→ Settings
→ Service role ARN
```

---

# 24. EC2DeployPermissions

We created an inline policy:

```text
EC2DeployPermissions
```

It provided permissions required by the EC2 deploy action, including:

```text
ec2:DescribeInstances

ssm:CancelCommand
ssm:DescribeInstanceInformation
ssm:ListCommandInvocations
ssm:SendCommand

logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
```

AWS's EC2 Deploy documentation lists these service-role permissions for the action. ([AWS Documentation][1])

The important missing permission from our first failure was:

```text
logs:PutLogEvents
```

After adding the policy, that IAM error was resolved.

---

# 25. Second Deployment Failure – DeploySpec Filename

After fixing IAM, the deployment got further.

The log showed:

```text
Found 1 instances
```

Then:

```text
DOWNLOAD succeeded
```

But:

```text
BEFORE_DEPLOY failed
```

The actual error was:

```text
ERROR [BeforeDeploy] Deploy spec deployspec.yaml not found
```

At first, CodePipeline was configured to search for:

```text
deployspec.yaml
```

But GitHub contained:

```text
deployspec.yml
```

This is an important lesson:

> **File names are exact. `.yaml` and `.yml` are different filenames.**

---

# 26. Fixing DeploySpec

We changed the CodePipeline configuration from:

```text
deployspec.yaml
```

to:

```text
deployspec.yml
```

The DeploySpec path is relative to the root of the input artifact, so the configured path needs to match the file in that artifact. AWS documents this behavior for the EC2 deploy action. ([AWS Documentation][1])

---

# 27. Final Successful Pipeline

After correcting the filename, the pipeline showed:

```text
Source  ✅
Build   ✅
Deploy  ✅
```

So our entire CI/CD pipeline was successful.

---

# 28. Final EC2 Verification

We SSHed into the EC2 instance and ran:

```bash
sudo systemctl status simple-python-app.service
```

The result showed:

```text
Active: active (running)
```

and:

```text
Main PID: ... (gunicorn)
```

We also saw:

```text
Listening at: http://0.0.0.0:8000
```

This proved Gunicorn was running.

---

# 29. Test the Application

We ran:

```bash
curl http://localhost:8000
```

The response was:

```text
Hello, world!
```

Therefore:

```text
Flask application
       ↓
Gunicorn
       ↓
EC2
```

was working correctly.

---

# 30. Final Architecture

The complete architecture we implemented is:

```text
                    ┌───────────────┐
                    │    GitHub     │
                    │ simple-python │
                    │     -app      │
                    └───────┬───────┘
                            │
                         git push
                            │
                            ▼
                 ┌────────────────────┐
                 │   CodePipeline V2  │
                 │                    │
                 │ Source → Build →   │
                 │ Deploy             │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │     CodeBuild      │
                 │                    │
                 │ buildspec.yml      │
                 │                    │
                 │ Install deps       │
                 │ Validate Python    │
                 │ Create artifact    │
                 └─────────┬──────────┘
                           │
                    BuildArtifact
                           │
                           ▼
                 ┌────────────────────┐
                 │ Amazon EC2 Deploy  │
                 │      Action        │
                 └─────────┬──────────┘
                           │
                      SSM SendCommand
                           │
                           ▼
                 ┌────────────────────┐
                 │   EC2 Ubuntu       │
                 │                    │
                 │ /home/ubuntu/      │
                 │ simple-python-app  │
                 └─────────┬──────────┘
                           │
                       systemd
                           │
                           ▼
                      Gunicorn
                           │
                       Port 8000
                           │
                           ▼
                     Flask App
                           │
                           ▼
                    "Hello, world!"
```

---

# 31. Important Concepts Learned

## CI

**Continuous Integration**

Developers frequently push code and the system automatically:

```text
Build
+
Validate
+
Test
```

our example:

```text
GitHub → CodeBuild
```

---

## CD

**Continuous Delivery/Deployment**

After the build succeeds, the application is automatically deployed.

Our example:

```text
CodeBuild
   ↓
EC2 Deploy
   ↓
EC2
```

---

# 32. Difference Between the AWS Services

| Service         | Responsibility                           |
| --------------- | ---------------------------------------- |
| GitHub          | Stores source code                       |
| CodePipeline    | Orchestrates workflow                    |
| CodeBuild       | Builds/validates application             |
| S3              | Stores CodePipeline artifacts internally |
| EC2             | Runs application                         |
| SSM             | Executes commands on EC2                 |
| IAM             | Controls permissions                     |
| CloudWatch Logs | Stores pipeline/build logs               |
| systemd         | Manages application service              |
| Gunicorn        | Runs Flask application                   |

---

# 33. Artifact Concept

This was an important concept.

The source starts in GitHub:

```text
GitHub
   ↓
SourceArtifact
```

Then CodeBuild processes it:

```text
SourceArtifact
      ↓
CodeBuild
      ↓
BuildArtifact
```

Then:

```text
BuildArtifact
      ↓
EC2 Deploy
```

The deploy action uses that artifact to deploy files to EC2. CodePipeline actions exchange these artifacts between stages. ([AWS Documentation][4])

---

# 34. IAM Roles We Used

There were multiple roles, and understanding their difference is important.

### CodePipeline service role

```text
AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

Purpose:

```text
CodePipeline → AWS services
```

For example:

```text
CodePipeline → CodeBuild
CodePipeline → CloudWatch Logs
CodePipeline → SSM
```

### CodeBuild service role

Something like:

```text
codebuild-simple-python-app-build-...
```

Purpose:

```text
CodeBuild → AWS resources required during build
```

### EC2 instance role

```text
CodeDeploy-EC2-Instance-Role
```

Purpose:

```text
EC2 → AWS Systems Manager
```

These are **different roles for different AWS services**.

---

# 35. Most Important Troubleshooting Lessons

## Problem 1: CodePipeline permission error

Error:

```text
logs:PutLogEvents
AccessDeniedException
```

Solution:

```text
Find CodePipeline service role
        ↓
Add required permissions
        ↓
Retry pipeline
```

---

## Problem 2: DeploySpec not found

Error:

```text
deployspec.yaml not found
```

Actual file:

```text
deployspec.yml
```

Solution:

```text
Make pipeline configuration
match actual filename.
```

---

## Problem 3: Application verification

Don't assume:

```text
Deploy = SUCCESS
```

means the application is definitely working.

We verified independently:

```bash
systemctl status simple-python-app.service
```

and:

```bash
curl http://localhost:8000
```

This gave:

```text
Hello, world!
```

That is much stronger verification.

---

# 36. Useful Commands for Future Reference

### Check application service

```bash
sudo systemctl status simple-python-app.service
```

### Start

```bash
sudo systemctl start simple-python-app.service
```

### Stop

```bash
sudo systemctl stop simple-python-app.service
```

### Restart

```bash
sudo systemctl restart simple-python-app.service
```

### Enable at boot

```bash
sudo systemctl enable simple-python-app.service
```

### Check logs

```bash
sudo journalctl -u simple-python-app.service
```

### Follow logs

```bash
sudo journalctl -u simple-python-app.service -f
```

### Test locally

```bash
curl http://localhost:8000
```

### Check listening port

```bash
sudo ss -tulpn | grep 8000
```

---

# 37. Git Workflow We Learned

The development workflow is now:

```text
1. Modify application
       ↓
2. git add .
       ↓
3. git commit -m "message"
       ↓
4. git push origin master
       ↓
5. GitHub detects change
       ↓
6. CodePipeline starts
       ↓
7. CodeBuild
       ↓
8. Deploy to EC2
```

So in the future, you shouldn't need to manually SSH into EC2 and copy every new version.

---

# 38. How a Future Code Change Will Work

Suppose we change:

```python
return 'Hello, world!'
```

to:

```python
return 'Hello from CI/CD!'
```

Then:

```bash
git add .
git commit -m "Update application message"
git push origin master
```

The pipeline detects the new commit.

Then:

```text
GitHub
  ↓
CodePipeline
  ↓
CodeBuild
  ↓
BuildArtifact
  ↓
EC2 Deploy
  ↓
SSM
  ↓
stop_app.sh
  ↓
Copy new application
  ↓
start_app.sh
  ↓
Gunicorn
  ↓
New Flask version
```

That is the core idea of **automated deployment**.

---

# 39. Why We Didn't Use Docker

For this first CI/CD exercise, we intentionally did **not** use Docker.

The goal was to understand:

```text
Git
CI
Build
Artifacts
CD
IAM
EC2
SSM
systemd
Gunicorn
```

first.

Docker/containerization can be added later.

A future architecture could become:

```text
GitHub
   ↓
CodePipeline
   ↓
CodeBuild
   ↓
Docker image
   ↓
ECR
   ↓
EC2 / ECS
```

But that is a separate learning step.

---

# 40. Key Takeaways

### 1. CodePipeline is the orchestrator

It connects:

```text
Source → Build → Deploy
```

### 2. CodeBuild performs the build

It follows:

```text
buildspec.yml
```

### 3. Artifacts move between stages

```text
SourceArtifact
      ↓
BuildArtifact
```

### 4. EC2 is the server

It actually runs the application.

### 5. SSM provides remote command execution

CodePipeline uses SSM to execute deployment operations on the EC2 instance. ([AWS Documentation][1])

### 6. IAM controls access

Each AWS service needs appropriate permissions.

### 7. DeploySpec controls deployment

```text
deployspec.yml
```

defines:

```text
where files go
what happens before deployment
what happens after deployment
```

### 8. systemd keeps the application running

```text
systemd
   ↓
Gunicorn
   ↓
Flask
```

### 9. Always verify the application

A green pipeline is not the only verification.

We also checked:

```bash
systemctl status
```

and:

```bash
curl
```

---

# 41. Final Result

We successfully implemented and verified:

```text
                    CI/CD PIPELINE

GitHub
  │
  │ Push
  ▼
CodePipeline
  │
  ├── Source       ✅
  │
  ├── Build        ✅
  │      │
  │      └── CodeBuild
  │
  └── Deploy       ✅
         │
         └── Amazon EC2
                │
                └── SSM
                      │
                      └── Ubuntu
                            │
                            └── systemd
                                  │
                                  └── Gunicorn
                                        │
                                        └── Flask
                                             │
                                             ▼
                                      Hello, world!
```

**Final status:**

```text
GitHub              ✅
CodePipeline        ✅
CodeBuild           ✅
IAM                 ✅
SSM                 ✅
EC2                 ✅
Deployment          ✅
systemd             ✅
Gunicorn            ✅
Flask               ✅
Application test    ✅
```

This is a solid set of notes to put into your **DevOps learning GitHub repository**.
# AWS CI/CD Learning Notes – Python Flask Application

This document records the complete CI/CD implementation we did for a simple Python Flask application using **GitHub + AWS CodePipeline + CodeBuild + Amazon EC2 + Systems Manager (SSM)**.

The goal was to understand a real CI/CD pipeline **without Docker** first.

---

# 1. Objective

We wanted to build this flow:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   ▼
AWS CodePipeline
   │
   ├── Source
   │
   ▼
AWS CodeBuild
   │
   │ Build + Validate + Create artifact
   ▼
Amazon EC2 Deploy Action
   │
   ▼
AWS Systems Manager (SSM)
   │
   ▼
EC2 Ubuntu Server
   │
   ▼
systemd
   │
   ▼
Gunicorn
   │
   ▼
Flask Application
```

The important concept is:

> **A developer pushes code to GitHub, and AWS automatically builds and deploys the application to EC2.**

AWS's EC2 deploy action supports Linux EC2 instances that are managed through Systems Manager/SSM Agent. ([AWS Documentation][1])

---

# 2. Application Used

We created a very simple Flask application.

### `app.py`

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, world!'

if __name__ == '__main__':
    app.run()
```

The application has one endpoint:

```text
/
```

and returns:

```text
Hello, world!
```

---

# 3. Project Structure

Our final GitHub repository structure is:

```text
simple-python-app/
│
├── app.py
├── requirements.txt
├── Procfile
├── buildspec.yml
├── deployspec.yml
├── README.md
│
└── scripts/
    ├── stop_app.sh
    └── start_app.sh
```

### Purpose of each file

| File               | Purpose                              |
| ------------------ | ------------------------------------ |
| `app.py`           | Flask application                    |
| `requirements.txt` | Python dependencies                  |
| `Procfile`         | Defines Gunicorn application command |
| `buildspec.yml`    | Instructions for CodeBuild           |
| `deployspec.yml`   | Instructions for EC2 deployment      |
| `start_app.sh`     | Starts/configures application        |
| `stop_app.sh`      | Stops existing application           |
| `README.md`        | Documentation                        |

---

# 4. `requirements.txt`

```text
Flask
gunicorn
```

We need:

* **Flask** → web framework
* **Gunicorn** → production WSGI server

---

# 5. Procfile

```text
web: gunicorn --bind :8000 app:app
```

This means:

```text
gunicorn
   ↓
app.py
   ↓
Flask object named "app"
```

The application listens on port:

```text
8000
```

---

# 6. AWS CodeBuild

## What is CodeBuild?

**AWS CodeBuild** is the build service.

It runs commands such as:

```text
install dependencies
run validation
run tests
compile/package application
create build artifact
```

AWS CodeBuild uses a **buildspec** file to define these commands. ([AWS Documentation][2])

---

# 7. `buildspec.yml`

We used:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.12

  pre_build:
    commands:
      - echo "Installing dependencies..."
      - pip install -r requirements.txt

  build:
    commands:
      - echo "Running application validation..."
      - python --version
      - python -m py_compile app.py

  post_build:
    commands:
      - echo "Build completed successfully!"

artifacts:
  files:
    - '**/*'
```

## Explanation

### Version

```yaml
version: 0.2
```

Defines the CodeBuild buildspec version.

### Install phase

```yaml
install:
  runtime-versions:
    python: 3.12
```

CodeBuild prepares Python 3.12.

### Pre-build

```yaml
pip install -r requirements.txt
```

Installs:

```text
Flask
Gunicorn
```

### Build

```bash
python --version
```

Checks Python.

Then:

```bash
python -m py_compile app.py
```

checks that the Python source can be compiled successfully.

### Post-build

Prints a successful completion message.

### Artifacts

```yaml
artifacts:
  files:
    - '**/*'
```

This tells CodeBuild to include all files recursively in the build output.

AWS documents `**/*` as a pattern that includes files recursively. ([AWS Documentation][2])

---

# 8. CodeBuild Project

We created:

```text
Project:
simple-python-app-build
```

### Source

GitHub:

```text
https://github.com/jntuhvijaya/simple-python-app
```

Branch:

```text
master
```

### Environment

We configured:

```text
Managed image
EC2
Ubuntu
Standard
aws/codebuild/standard:8.0
2 vCPU
4 GiB
Python 3.12
```

Privileged mode:

```text
OFF
```

This was intentional because we were **not using Docker**.

---

# 9. CodeBuild Testing

Before connecting CodeBuild to CodePipeline, we manually ran a CodeBuild build.

The build successfully completed:

```text
Source download       SUCCESS
Install                SUCCESS
Pre-build              SUCCESS
Build                  SUCCESS
Post-build             SUCCESS
Artifacts              SUCCESS
```

The important validation was:

```text
python -m py_compile app.py
```

which succeeded.

---

# 10. Amazon EC2

We created an Ubuntu EC2 instance.

Important configuration:

```text
AMI: Ubuntu
Instance type: t3.micro
```

We gave the instance the name:

```text
simple-python-app-server
```

This tag became important later because CodePipeline uses the tag to find the deployment target.

### EC2 tag

```text
Name = simple-python-app-server
```

---

# 11. EC2 IAM Role

We created an EC2 instance role:

```text
CodeDeploy-EC2-Instance-Role
```

The instance was given permissions needed for Systems Manager.

The SSM Agent on an EC2 instance uses permissions supplied through the EC2 instance profile/role. ([AWS Documentation][3])

---

# 12. AWS Systems Manager / SSM

Instead of using CodeDeploy, we used the **Amazon EC2 Deploy action in CodePipeline with SSM**.

This was important because our CodeDeploy console setup was blocked by the account setup issue.

The architecture became:

```text
CodePipeline
      ↓
EC2 Deploy Action
      ↓
SSM
      ↓
EC2
```

AWS's current documentation confirms that the EC2 deploy action can deploy to Linux EC2 instances that are SSM-managed and requires the SSM Agent. ([AWS Documentation][1])

---

# 13. Verify SSM Agent

Initially we checked:

```bash
sudo systemctl status amazon-ssm-agent
```

The Ubuntu installation used Snap.

We found that SSM Agent was already installed and then verified:

```bash
sudo snap list amazon-ssm-agent
```

and:

```bash
sudo snap services amazon-ssm-agent
```

The service was active.

In Systems Manager → Managed Nodes, our EC2 instance appeared as:

```text
Running
Ping: Online
Agent: 3.3.4121.0
```

This confirmed:

```text
EC2
 ↓
SSM Agent
 ↓
AWS Systems Manager
```

was working.

---

# 14. Deployment Files

We created a deployment specification:

```text
deployspec.yml
```

Important: **the filename is `.yml`, not `.yaml`.**

This caused one of our deployment failures later.

---

# 15. `deployspec.yml`

```yaml
version: 0.1

files:
  - source: /
    destination: /home/ubuntu/simple-python-app/

scripts:
  BeforeDeploy:
    - location: scripts/stop_app.sh
      timeout: 300
      runas: root

  AfterDeploy:
    - location: scripts/start_app.sh
      timeout: 600
      runas: root
```

## What does this do?

### Files section

```yaml
source: /
```

Means take the deployment artifact.

```yaml
destination: /home/ubuntu/simple-python-app/
```

Copy the application to:

```text
/home/ubuntu/simple-python-app/
```

### BeforeDeploy

Runs:

```text
scripts/stop_app.sh
```

before the new application is deployed.

### AfterDeploy

Runs:

```text
scripts/start_app.sh
```

after the files have been deployed.

---

# 16. `stop_app.sh`

```bash
#!/bin/bash

echo "Stopping Flask application..."

systemctl stop simple-python-app.service || true

echo "Application stopped."
```

This stops the currently running application.

The:

```bash
|| true
```

means that if the service does not exist yet, the deployment should continue instead of failing.

---

# 17. `start_app.sh`

The script performs several tasks.

```bash
#!/bin/bash

set -e

APP_DIR="/home/ubuntu/simple-python-app"
VENV_DIR="$APP_DIR/venv"
SERVICE_FILE="/etc/systemd/system/simple-python-app.service"
```

### Step 1 — Change ownership

```bash
chown -R ubuntu:ubuntu "$APP_DIR"
```

Makes the `ubuntu` user the owner.

### Step 2 — Install virtual environment support

```bash
apt-get update
apt-get install -y python3-venv
```

### Step 3 — Create virtual environment

```bash
python3 -m venv "$VENV_DIR"
```

### Step 4 — Install dependencies

```bash
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt"
```

This installs Flask and Gunicorn.

### Step 5 — Create systemd service

We created:

```text
/etc/systemd/system/simple-python-app.service
```

with:

```ini
[Unit]
Description=Simple Python Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/simple-python-app
ExecStart=/home/ubuntu/simple-python-app/venv/bin/gunicorn --bind 0.0.0.0:8000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

This makes Gunicorn run as a Linux service.

### Step 6 — Reload systemd

```bash
systemctl daemon-reload
```

### Step 7 — Enable service

```bash
systemctl enable simple-python-app.service
```

This allows the service to start automatically when the system boots.

### Step 8 — Start application

```bash
systemctl restart simple-python-app.service
```

---

# 18. CodePipeline

We created:

```text
simple-python-app-pipeline
```

Pipeline type:

```text
V2
```

Execution mode:

```text
QUEUED
```

---

# 19. Source Stage

Source provider:

```text
GitHub via GitHub App
```

Repository:

```text
jntuhvijaya/simple-python-app
```

Branch:

```text
master
```

Change detection:

```text
Enabled
```

So when code is pushed to `master`, CodePipeline can detect the change and start the pipeline.

---

# 20. Build Stage

Build provider:

```text
AWS CodeBuild
```

Project:

```text
simple-python-app-build
```

Input:

```text
SourceArtifact
```

Output:

```text
BuildArtifact
```

The CodeBuild action receives the source artifact and can make its output available to later CodePipeline actions. ([AWS Documentation][4])

---

# 21. Deploy Stage

Provider:

```text
Amazon EC2
```

Region:

```text
us-east-1
```

Instance type:

```text
EC2
```

Target tag:

```text
Key:   Name
Value: simple-python-app-server
```

Therefore CodePipeline searches for:

```text
Name = simple-python-app-server
```

and found our instance:

```text
i-0a1b9f16bf7ce90c
```

The EC2 deploy action supports targeting Linux EC2 instances and uses SSM to execute deployment commands. ([AWS Documentation][1])

---

# 22. First Pipeline Failure – IAM Permission

Our first deployment failed with:

```text
AccessDeniedException
```

Specifically:

```text
logs:PutLogEvents
```

The CodePipeline service role did not have the required CloudWatch Logs permission.

---

# 23. Finding the Correct IAM Role

The CodePipeline service role was:

```text
AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

Its ARN was:

```text
arn:aws:iam::853617422750:role/service-role/AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

We opened that role from:

```text
CodePipeline
→ Settings
→ Service role ARN
```

---

# 24. EC2DeployPermissions

We created an inline policy:

```text
EC2DeployPermissions
```

It provided permissions required by the EC2 deploy action, including:

```text
ec2:DescribeInstances

ssm:CancelCommand
ssm:DescribeInstanceInformation
ssm:ListCommandInvocations
ssm:SendCommand

logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
```

AWS's EC2 Deploy documentation lists these service-role permissions for the action. ([AWS Documentation][1])

The important missing permission from our first failure was:

```text
logs:PutLogEvents
```

After adding the policy, that IAM error was resolved.

---

# 25. Second Deployment Failure – DeploySpec Filename

After fixing IAM, the deployment got further.

The log showed:

```text
Found 1 instances
```

Then:

```text
DOWNLOAD succeeded
```

But:

```text
BEFORE_DEPLOY failed
```

The actual error was:

```text
ERROR [BeforeDeploy] Deploy spec deployspec.yaml not found
```

At first, CodePipeline was configured to search for:

```text
deployspec.yaml
```

But GitHub contained:

```text
deployspec.yml
```

This is an important lesson:

> **File names are exact. `.yaml` and `.yml` are different filenames.**

---

# 26. Fixing DeploySpec

We changed the CodePipeline configuration from:

```text
deployspec.yaml
```

to:

```text
deployspec.yml
```

The DeploySpec path is relative to the root of the input artifact, so the configured path needs to match the file in that artifact. AWS documents this behavior for the EC2 deploy action. ([AWS Documentation][1])

---

# 27. Final Successful Pipeline

After correcting the filename, the pipeline showed:

```text
Source  ✅
Build   ✅
Deploy  ✅
```

So our entire CI/CD pipeline was successful.

---

# 28. Final EC2 Verification

We SSHed into the EC2 instance and ran:

```bash
sudo systemctl status simple-python-app.service
```

The result showed:

```text
Active: active (running)
```

and:

```text
Main PID: ... (gunicorn)
```

We also saw:

```text
Listening at: http://0.0.0.0:8000
```

This proved Gunicorn was running.

---

# 29. Test the Application

We ran:

```bash
curl http://localhost:8000
```

The response was:

```text
Hello, world!
```

Therefore:

```text
Flask application
       ↓
Gunicorn
       ↓
EC2
```

was working correctly.

---

# 30. Final Architecture

The complete architecture we implemented is:

```text
                    ┌───────────────┐
                    │    GitHub     │
                    │ simple-python │
                    │     -app      │
                    └───────┬───────┘
                            │
                         git push
                            │
                            ▼
                 ┌────────────────────┐
                 │   CodePipeline V2  │
                 │                    │
                 │ Source → Build →   │
                 │ Deploy             │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │     CodeBuild      │
                 │                    │
                 │ buildspec.yml      │
                 │                    │
                 │ Install deps       │
                 │ Validate Python    │
                 │ Create artifact    │
                 └─────────┬──────────┘
                           │
                    BuildArtifact
                           │
                           ▼
                 ┌────────────────────┐
                 │ Amazon EC2 Deploy  │
                 │      Action        │
                 └─────────┬──────────┘
                           │
                      SSM SendCommand
                           │
                           ▼
                 ┌────────────────────┐
                 │   EC2 Ubuntu       │
                 │                    │
                 │ /home/ubuntu/      │
                 │ simple-python-app  │
                 └─────────┬──────────┘
                           │
                       systemd
                           │
                           ▼
                      Gunicorn
                           │
                       Port 8000
                           │
                           ▼
                     Flask App
                           │
                           ▼
                    "Hello, world!"
```

---

# 31. Important Concepts Learned

## CI

**Continuous Integration**

Developers frequently push code and the system automatically:

```text
Build
+
Validate
+
Test
```

our example:

```text
GitHub → CodeBuild
```

---

## CD

**Continuous Delivery/Deployment**

After the build succeeds, the application is automatically deployed.

Our example:

```text
CodeBuild
   ↓
EC2 Deploy
   ↓
EC2
```

---

# 32. Difference Between the AWS Services

| Service         | Responsibility                           |
| --------------- | ---------------------------------------- |
| GitHub          | Stores source code                       |
| CodePipeline    | Orchestrates workflow                    |
| CodeBuild       | Builds/validates application             |
| S3              | Stores CodePipeline artifacts internally |
| EC2             | Runs application                         |
| SSM             | Executes commands on EC2                 |
| IAM             | Controls permissions                     |
| CloudWatch Logs | Stores pipeline/build logs               |
| systemd         | Manages application service              |
| Gunicorn        | Runs Flask application                   |

---

# 33. Artifact Concept

This was an important concept.

The source starts in GitHub:

```text
GitHub
   ↓
SourceArtifact
```

Then CodeBuild processes it:

```text
SourceArtifact
      ↓
CodeBuild
      ↓
BuildArtifact
```

Then:

```text
BuildArtifact
      ↓
EC2 Deploy
```

The deploy action uses that artifact to deploy files to EC2. CodePipeline actions exchange these artifacts between stages. ([AWS Documentation][4])

---

# 34. IAM Roles We Used

There were multiple roles, and understanding their difference is important.

### CodePipeline service role

```text
AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

Purpose:

```text
CodePipeline → AWS services
```

For example:

```text
CodePipeline → CodeBuild
CodePipeline → CloudWatch Logs
CodePipeline → SSM
```

### CodeBuild service role

Something like:

```text
codebuild-simple-python-app-build-...
```

Purpose:

```text
CodeBuild → AWS resources required during build
```

### EC2 instance role

```text
CodeDeploy-EC2-Instance-Role
```

Purpose:

```text
EC2 → AWS Systems Manager
```

These are **different roles for different AWS services**.

---

# 35. Most Important Troubleshooting Lessons

## Problem 1: CodePipeline permission error

Error:

```text
logs:PutLogEvents
AccessDeniedException
```

Solution:

```text
Find CodePipeline service role
        ↓
Add required permissions
        ↓
Retry pipeline
```

---

## Problem 2: DeploySpec not found

Error:

```text
deployspec.yaml not found
```

Actual file:

```text
deployspec.yml
```

Solution:

```text
Make pipeline configuration
match actual filename.
```

---

## Problem 3: Application verification

Don't assume:

```text
Deploy = SUCCESS
```

means the application is definitely working.

We verified independently:

```bash
systemctl status simple-python-app.service
```

and:

```bash
curl http://localhost:8000
```

This gave:

```text
Hello, world!
```

That is much stronger verification.

---

# 36. Useful Commands for Future Reference

### Check application service

```bash
sudo systemctl status simple-python-app.service
```

### Start

```bash
sudo systemctl start simple-python-app.service
```

### Stop

```bash
sudo systemctl stop simple-python-app.service
```

### Restart

```bash
sudo systemctl restart simple-python-app.service
```

### Enable at boot

```bash
sudo systemctl enable simple-python-app.service
```

### Check logs

```bash
sudo journalctl -u simple-python-app.service
```

### Follow logs

```bash
sudo journalctl -u simple-python-app.service -f
```

### Test locally

```bash
curl http://localhost:8000
```

### Check listening port

```bash
sudo ss -tulpn | grep 8000
```

---

# 37. Git Workflow We Learned

The development workflow is now:

```text
1. Modify application
       ↓
2. git add .
       ↓
3. git commit -m "message"
       ↓
4. git push origin master
       ↓
5. GitHub detects change
       ↓
6. CodePipeline starts
       ↓
7. CodeBuild
       ↓
8. Deploy to EC2
```

So in the future, you shouldn't need to manually SSH into EC2 and copy every new version.

---

# 38. How a Future Code Change Will Work

Suppose we change:

```python
return 'Hello, world!'
```

to:

```python
return 'Hello from CI/CD!'
```

Then:

```bash
git add .
git commit -m "Update application message"
git push origin master
```

The pipeline detects the new commit.

Then:

```text
GitHub
  ↓
CodePipeline
  ↓
CodeBuild
  ↓
BuildArtifact
  ↓
EC2 Deploy
  ↓
SSM
  ↓
stop_app.sh
  ↓
Copy new application
  ↓
start_app.sh
  ↓
Gunicorn
  ↓
New Flask version
```

That is the core idea of **automated deployment**.

---

# 39. Why We Didn't Use Docker

For this first CI/CD exercise, we intentionally did **not** use Docker.

The goal was to understand:

```text
Git
CI
Build
Artifacts
CD
IAM
EC2
SSM
systemd
Gunicorn
```

first.

Docker/containerization can be added later.

A future architecture could become:

```text
GitHub
   ↓
CodePipeline
   ↓
CodeBuild
   ↓
Docker image
   ↓
ECR
   ↓
EC2 / ECS
```

But that is a separate learning step.

---

# 40. Key Takeaways

### 1. CodePipeline is the orchestrator

It connects:

```text
Source → Build → Deploy
```

### 2. CodeBuild performs the build

It follows:

```text
buildspec.yml
```

### 3. Artifacts move between stages

```text
SourceArtifact
      ↓
BuildArtifact
```

### 4. EC2 is the server

It actually runs the application.

### 5. SSM provides remote command execution

CodePipeline uses SSM to execute deployment operations on the EC2 instance. ([AWS Documentation][1])

### 6. IAM controls access

Each AWS service needs appropriate permissions.

### 7. DeploySpec controls deployment

```text
deployspec.yml
```

defines:

```text
where files go
what happens before deployment
what happens after deployment
```

### 8. systemd keeps the application running

```text
systemd
   ↓
Gunicorn
   ↓
Flask
```

### 9. Always verify the application

A green pipeline is not the only verification.

We also checked:

```bash
systemctl status
```

and:

```bash
curl
```

---

# 41. Final Result

We successfully implemented and verified:

```text
                    CI/CD PIPELINE

GitHub
  │
  │ Push
  ▼
CodePipeline
  │
  ├── Source       ✅
  │
  ├── Build        ✅
  │      │
  │      └── CodeBuild
  │
  └── Deploy       ✅
         │
         └── Amazon EC2
                │
                └── SSM
                      │
                      └── Ubuntu
                            │
                            └── systemd
                                  │
                                  └── Gunicorn
                                        │
                                        └── Flask
                                             │
                                             ▼
                                      Hello, world!
```

**Final status:**

```text
GitHub              ✅
CodePipeline        ✅
CodeBuild           ✅
IAM                 ✅
SSM                 ✅
EC2                 ✅
Deployment          ✅
systemd             ✅
Gunicorn            ✅
Flask               ✅
Application test    ✅
```

This is a solid set of notes to put into your **DevOps learning GitHub repository**. 
# AWS CI/CD Learning Notes – Python Flask Application

This document records the complete CI/CD implementation we did for a simple Python Flask application using **GitHub + AWS CodePipeline + CodeBuild + Amazon EC2 + Systems Manager (SSM)**.

The goal was to understand a real CI/CD pipeline **without Docker** first.

---

# 1. Objective

We wanted to build this flow:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   ▼
AWS CodePipeline
   │
   ├── Source
   │
   ▼
AWS CodeBuild
   │
   │ Build + Validate + Create artifact
   ▼
Amazon EC2 Deploy Action
   │
   ▼
AWS Systems Manager (SSM)
   │
   ▼
EC2 Ubuntu Server
   │
   ▼
systemd
   │
   ▼
Gunicorn
   │
   ▼
Flask Application
```

The important concept is:

> **A developer pushes code to GitHub, and AWS automatically builds and deploys the application to EC2.**

AWS's EC2 deploy action supports Linux EC2 instances that are managed through Systems Manager/SSM Agent. ([AWS Documentation][1])

---

# 2. Application Used

We created a very simple Flask application.

### `app.py`

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, world!'

if __name__ == '__main__':
    app.run()
```

The application has one endpoint:

```text
/
```

and returns:

```text
Hello, world!
```

---

# 3. Project Structure

Our final GitHub repository structure is:

```text
simple-python-app/
│
├── app.py
├── requirements.txt
├── Procfile
├── buildspec.yml
├── deployspec.yml
├── README.md
│
└── scripts/
    ├── stop_app.sh
    └── start_app.sh
```

### Purpose of each file

| File               | Purpose                              |
| ------------------ | ------------------------------------ |
| `app.py`           | Flask application                    |
| `requirements.txt` | Python dependencies                  |
| `Procfile`         | Defines Gunicorn application command |
| `buildspec.yml`    | Instructions for CodeBuild           |
| `deployspec.yml`   | Instructions for EC2 deployment      |
| `start_app.sh`     | Starts/configures application        |
| `stop_app.sh`      | Stops existing application           |
| `README.md`        | Documentation                        |

---

# 4. `requirements.txt`

```text
Flask
gunicorn
```

We need:

* **Flask** → web framework
* **Gunicorn** → production WSGI server

---

# 5. Procfile

```text
web: gunicorn --bind :8000 app:app
```

This means:

```text
gunicorn
   ↓
app.py
   ↓
Flask object named "app"
```

The application listens on port:

```text
8000
```

---

# 6. AWS CodeBuild

## What is CodeBuild?

**AWS CodeBuild** is the build service.

It runs commands such as:

```text
install dependencies
run validation
run tests
compile/package application
create build artifact
```

AWS CodeBuild uses a **buildspec** file to define these commands. ([AWS Documentation][2])

---

# 7. `buildspec.yml`

We used:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.12

  pre_build:
    commands:
      - echo "Installing dependencies..."
      - pip install -r requirements.txt

  build:
    commands:
      - echo "Running application validation..."
      - python --version
      - python -m py_compile app.py

  post_build:
    commands:
      - echo "Build completed successfully!"

artifacts:
  files:
    - '**/*'
```

## Explanation

### Version

```yaml
version: 0.2
```

Defines the CodeBuild buildspec version.

### Install phase

```yaml
install:
  runtime-versions:
    python: 3.12
```

CodeBuild prepares Python 3.12.

### Pre-build

```yaml
pip install -r requirements.txt
```

Installs:

```text
Flask
Gunicorn
```

### Build

```bash
python --version
```

Checks Python.

Then:

```bash
python -m py_compile app.py
```

checks that the Python source can be compiled successfully.

### Post-build

Prints a successful completion message.

### Artifacts

```yaml
artifacts:
  files:
    - '**/*'
```

This tells CodeBuild to include all files recursively in the build output.

AWS documents `**/*` as a pattern that includes files recursively. ([AWS Documentation][2])

---

# 8. CodeBuild Project

We created:

```text
Project:
simple-python-app-build
```

### Source

GitHub:

```text
https://github.com/jntuhvijaya/simple-python-app
```

Branch:

```text
master
```
<img width="1905" height="788" alt="Screenshot 2026-09-23 165705" src="https://github.com/user-attachments/assets/b0d13467-71c0-4242-be07-84cd03d76b14" />


### Environment

We configured:

```text
Managed image
EC2
Ubuntu
Standard
aws/codebuild/standard:8.0
2 vCPU
4 GiB
Python 3.12
```

Privileged mode:

```text
OFF
```

This was intentional because we were **not using Docker**.

---

# 9. CodeBuild Testing

Before connecting CodeBuild to CodePipeline, we manually ran a CodeBuild build.

The build successfully completed:

```text
Source download       SUCCESS
Install                SUCCESS
Pre-build              SUCCESS
Build                  SUCCESS
Post-build             SUCCESS
Artifacts              SUCCESS
```

The important validation was:

```text
python -m py_compile app.py
```

which succeeded.

---

# 10. Amazon EC2

We created an Ubuntu EC2 instance.

Important configuration:

```text
AMI: Ubuntu
Instance type: t3.micro
```

We gave the instance the name:

```text
simple-python-app-server
```

This tag became important later because CodePipeline uses the tag to find the deployment target.

### EC2 tag

```text
Name = simple-python-app-server
```

---

# 11. EC2 IAM Role

We created an EC2 instance role:

```text
CodeDeploy-EC2-Instance-Role
```

The instance was given permissions needed for Systems Manager.

The SSM Agent on an EC2 instance uses permissions supplied through the EC2 instance profile/role. ([AWS Documentation][3])

---

# 12. AWS Systems Manager / SSM

Instead of using CodeDeploy, we used the **Amazon EC2 Deploy action in CodePipeline with SSM**.

This was important because our CodeDeploy console setup was blocked by the account setup issue.

The architecture became:

```text
CodePipeline
      ↓
EC2 Deploy Action
      ↓
SSM
      ↓
EC2
```

AWS's current documentation confirms that the EC2 deploy action can deploy to Linux EC2 instances that are SSM-managed and requires the SSM Agent. ([AWS Documentation][1])

---

# 13. Verify SSM Agent

Initially we checked:

```bash
sudo systemctl status amazon-ssm-agent
```

The Ubuntu installation used Snap.

We found that SSM Agent was already installed and then verified:

```bash
sudo snap list amazon-ssm-agent
```

and:

```bash
sudo snap services amazon-ssm-agent
```

The service was active.

In Systems Manager → Managed Nodes, our EC2 instance appeared as:

```text
Running
Ping: Online
Agent: 3.3.4121.0
```

This confirmed:

```text
EC2
 ↓
SSM Agent
 ↓
AWS Systems Manager
```

was working.

---

# 14. Deployment Files

We created a deployment specification:

```text
deployspec.yml
```

Important: **the filename is `.yml`, not `.yaml`.**

This caused one of our deployment failures later.

---

# 15. `deployspec.yml`

```yaml
version: 0.1

files:
  - source: /
    destination: /home/ubuntu/simple-python-app/

scripts:
  BeforeDeploy:
    - location: scripts/stop_app.sh
      timeout: 300
      runas: root

  AfterDeploy:
    - location: scripts/start_app.sh
      timeout: 600
      runas: root
```

## What does this do?

### Files section

```yaml
source: /
```

Means take the deployment artifact.

```yaml
destination: /home/ubuntu/simple-python-app/
```

Copy the application to:

```text
/home/ubuntu/simple-python-app/
```

### BeforeDeploy

Runs:

```text
scripts/stop_app.sh
```

before the new application is deployed.

### AfterDeploy

Runs:

```text
scripts/start_app.sh
```

after the files have been deployed.

---

# 16. `stop_app.sh`

```bash
#!/bin/bash

echo "Stopping Flask application..."

systemctl stop simple-python-app.service || true

echo "Application stopped."
```

This stops the currently running application.

The:

```bash
|| true
```

means that if the service does not exist yet, the deployment should continue instead of failing.

---

# 17. `start_app.sh`

The script performs several tasks.

```bash
#!/bin/bash

set -e

APP_DIR="/home/ubuntu/simple-python-app"
VENV_DIR="$APP_DIR/venv"
SERVICE_FILE="/etc/systemd/system/simple-python-app.service"
```

### Step 1 — Change ownership

```bash
chown -R ubuntu:ubuntu "$APP_DIR"
```

Makes the `ubuntu` user the owner.

### Step 2 — Install virtual environment support

```bash
apt-get update
apt-get install -y python3-venv
```

### Step 3 — Create virtual environment

```bash
python3 -m venv "$VENV_DIR"
```

### Step 4 — Install dependencies

```bash
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt"
```

This installs Flask and Gunicorn.

### Step 5 — Create systemd service

We created:

```text
/etc/systemd/system/simple-python-app.service
```

with:

```ini
[Unit]
Description=Simple Python Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/simple-python-app
ExecStart=/home/ubuntu/simple-python-app/venv/bin/gunicorn --bind 0.0.0.0:8000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

This makes Gunicorn run as a Linux service.

### Step 6 — Reload systemd

```bash
systemctl daemon-reload
```

### Step 7 — Enable service

```bash
systemctl enable simple-python-app.service
```

This allows the service to start automatically when the system boots.

### Step 8 — Start application

```bash
systemctl restart simple-python-app.service
```

---

# 18. CodePipeline

We created:

```text
simple-python-app-pipeline
```

Pipeline type:

```text
V2
```

Execution mode:

```text
QUEUED
```

---

# 19. Source Stage

Source provider:

```text
GitHub via GitHub App
```

Repository:

```text
jntuhvijaya/simple-python-app
```

Branch:

```text
master
```

Change detection:

```text
Enabled
```

So when code is pushed to `master`, CodePipeline can detect the change and start the pipeline.

---

# 20. Build Stage

Build provider:

```text
AWS CodeBuild
```

Project:

```text
simple-python-app-build
```

Input:

```text
SourceArtifact
```

Output:

```text
BuildArtifact
```

The CodeBuild action receives the source artifact and can make its output available to later CodePipeline actions. ([AWS Documentation][4])

---

# 21. Deploy Stage

Provider:

```text
Amazon EC2
```

Region:

```text
us-east-1
```

Instance type:

```text
EC2
```

Target tag:

```text
Key:   Name
Value: simple-python-app-server
```

Therefore CodePipeline searches for:

```text
Name = simple-python-app-server
```

and found our instance:

```text
i-0a1b9f16bf7ce90c
```

The EC2 deploy action supports targeting Linux EC2 instances and uses SSM to execute deployment commands. ([AWS Documentation][1])

---

# 22. First Pipeline Failure – IAM Permission

Our first deployment failed with:

```text
AccessDeniedException
```

Specifically:

```text
logs:PutLogEvents
```

The CodePipeline service role did not have the required CloudWatch Logs permission.

---

# 23. Finding the Correct IAM Role

The CodePipeline service role was:

```text
AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

Its ARN was:

```text
arn:aws:iam::853617422750:role/service-role/AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

We opened that role from:

```text
CodePipeline
→ Settings
→ Service role ARN
```

---

# 24. EC2DeployPermissions

We created an inline policy:

```text
EC2DeployPermissions
```

It provided permissions required by the EC2 deploy action, including:

```text
ec2:DescribeInstances

ssm:CancelCommand
ssm:DescribeInstanceInformation
ssm:ListCommandInvocations
ssm:SendCommand

logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
```

AWS's EC2 Deploy documentation lists these service-role permissions for the action. ([AWS Documentation][1])

The important missing permission from our first failure was:

```text
logs:PutLogEvents
```

After adding the policy, that IAM error was resolved.

---

# 25. Second Deployment Failure – DeploySpec Filename

After fixing IAM, the deployment got further.

The log showed:

```text
Found 1 instances
```

Then:

```text
DOWNLOAD succeeded
```

But:

```text
BEFORE_DEPLOY failed
```

The actual error was:

```text
ERROR [BeforeDeploy] Deploy spec deployspec.yaml not found
```

At first, CodePipeline was configured to search for:

```text
deployspec.yaml
```

But GitHub contained:

```text
deployspec.yml
```

This is an important lesson:

> **File names are exact. `.yaml` and `.yml` are different filenames.**

---

# 26. Fixing DeploySpec

We changed the CodePipeline configuration from:

```text
deployspec.yaml
```

to:

```text
deployspec.yml
```

The DeploySpec path is relative to the root of the input artifact, so the configured path needs to match the file in that artifact. AWS documents this behavior for the EC2 deploy action. ([AWS Documentation][1])

---

# 27. Final Successful Pipeline

After correcting the filename, the pipeline showed:

```text
Source  ✅
Build   ✅
Deploy  ✅
```

So our entire CI/CD pipeline was successful.

---

# 28. Final EC2 Verification

We SSHed into the EC2 instance and ran:

```bash
sudo systemctl status simple-python-app.service
```

The result showed:

```text
Active: active (running)
```

and:

```text
Main PID: ... (gunicorn)
```

We also saw:

```text
Listening at: http://0.0.0.0:8000
```

This proved Gunicorn was running.

---

# 29. Test the Application

We ran:

```bash
curl http://localhost:8000
```

The response was:

```text
Hello, world!
```

Therefore:

```text
Flask application
       ↓
Gunicorn
       ↓
EC2
```

was working correctly.

---

# 30. Final Architecture

The complete architecture we implemented is:

```text
                    ┌───────────────┐
                    │    GitHub     │
                    │ simple-python │
                    │     -app      │
                    └───────┬───────┘
                            │
                         git push
                            │
                            ▼
                 ┌────────────────────┐
                 │   CodePipeline V2  │
                 │                    │
                 │ Source → Build →   │
                 │ Deploy             │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │     CodeBuild      │
                 │                    │
                 │ buildspec.yml      │
                 │                    │
                 │ Install deps       │
                 │ Validate Python    │
                 │ Create artifact    │
                 └─────────┬──────────┘
                           │
                    BuildArtifact
                           │
                           ▼
                 ┌────────────────────┐
                 │ Amazon EC2 Deploy  │
                 │      Action        │
                 └─────────┬──────────┘
                           │
                      SSM SendCommand
                           │
                           ▼
                 ┌────────────────────┐
                 │   EC2 Ubuntu       │
                 │                    │
                 │ /home/ubuntu/      │
                 │ simple-python-app  │
                 └─────────┬──────────┘
                           │
                       systemd
                           │
                           ▼
                      Gunicorn
                           │
                       Port 8000
                           │
                           ▼
                     Flask App
                           │
                           ▼
                    "Hello, world!"
```

---

# 31. Important Concepts Learned

## CI

**Continuous Integration**

Developers frequently push code and the system automatically:

```text
Build
+
Validate
+
Test
```

our example:

```text
GitHub → CodeBuild
```

---

## CD

**Continuous Delivery/Deployment**

After the build succeeds, the application is automatically deployed.

Our example:

```text
CodeBuild
   ↓
EC2 Deploy
   ↓
EC2
```

---

# 32. Difference Between the AWS Services

| Service         | Responsibility                           |
| --------------- | ---------------------------------------- |
| GitHub          | Stores source code                       |
| CodePipeline    | Orchestrates workflow                    |
| CodeBuild       | Builds/validates application             |
| S3              | Stores CodePipeline artifacts internally |
| EC2             | Runs application                         |
| SSM             | Executes commands on EC2                 |
| IAM             | Controls permissions                     |
| CloudWatch Logs | Stores pipeline/build logs               |
| systemd         | Manages application service              |
| Gunicorn        | Runs Flask application                   |

---

# 33. Artifact Concept

This was an important concept.

The source starts in GitHub:

```text
GitHub
   ↓
SourceArtifact
```

Then CodeBuild processes it:

```text
SourceArtifact
      ↓
CodeBuild
      ↓
BuildArtifact
```

Then:

```text
BuildArtifact
      ↓
EC2 Deploy
```

The deploy action uses that artifact to deploy files to EC2. CodePipeline actions exchange these artifacts between stages. ([AWS Documentation][4])

---

# 34. IAM Roles We Used

There were multiple roles, and understanding their difference is important.

### CodePipeline service role

```text
AWSCodePipelineServiceRole-us-east-1-simple-python-app-pipeline
```

Purpose:

```text
CodePipeline → AWS services
```

For example:

```text
CodePipeline → CodeBuild
CodePipeline → CloudWatch Logs
CodePipeline → SSM
```

### CodeBuild service role

Something like:

```text
codebuild-simple-python-app-build-...
```

Purpose:

```text
CodeBuild → AWS resources required during build
```

### EC2 instance role

```text
CodeDeploy-EC2-Instance-Role
```

Purpose:

```text
EC2 → AWS Systems Manager
```

These are **different roles for different AWS services**.

---

# 35. Most Important Troubleshooting Lessons

## Problem 1: CodePipeline permission error

Error:

```text
logs:PutLogEvents
AccessDeniedException
```

Solution:

```text
Find CodePipeline service role
        ↓
Add required permissions
        ↓
Retry pipeline
```

---

## Problem 2: DeploySpec not found

Error:

```text
deployspec.yaml not found
```

Actual file:

```text
deployspec.yml
```

Solution:

```text
Make pipeline configuration
match actual filename.
```

---

## Problem 3: Application verification

Don't assume:

```text
Deploy = SUCCESS
```

means the application is definitely working.

We verified independently:

```bash
systemctl status simple-python-app.service
```

and:

```bash
curl http://localhost:8000
```

This gave:

```text
Hello, world!
```

That is much stronger verification.

---

# 36. Useful Commands for Future Reference

### Check application service

```bash
sudo systemctl status simple-python-app.service
```

### Start

```bash
sudo systemctl start simple-python-app.service
```

### Stop

```bash
sudo systemctl stop simple-python-app.service
```

### Restart

```bash
sudo systemctl restart simple-python-app.service
```

### Enable at boot

```bash
sudo systemctl enable simple-python-app.service
```

### Check logs

```bash
sudo journalctl -u simple-python-app.service
```

### Follow logs

```bash
sudo journalctl -u simple-python-app.service -f
```

### Test locally

```bash
curl http://localhost:8000
```

### Check listening port

```bash
sudo ss -tulpn | grep 8000
```

---

# 37. Git Workflow We Learned

The development workflow is now:

```text
1. Modify application
       ↓
2. git add .
       ↓
3. git commit -m "message"
       ↓
4. git push origin master
       ↓
5. GitHub detects change
       ↓
6. CodePipeline starts
       ↓
7. CodeBuild
       ↓
8. Deploy to EC2
```

So in the future, you shouldn't need to manually SSH into EC2 and copy every new version.

---

# 38. How a Future Code Change Will Work

Suppose we change:

```python
return 'Hello, world!'
```

to:

```python
return 'Hello from CI/CD!'
```

Then:

```bash
git add .
git commit -m "Update application message"
git push origin master
```

The pipeline detects the new commit.

Then:

```text
GitHub
  ↓
CodePipeline
  ↓
CodeBuild
  ↓
BuildArtifact
  ↓
EC2 Deploy
  ↓
SSM
  ↓
stop_app.sh
  ↓
Copy new application
  ↓
start_app.sh
  ↓
Gunicorn
  ↓
New Flask version
```

That is the core idea of **automated deployment**.

---

# 39. Why We Didn't Use Docker

For this first CI/CD exercise, we intentionally did **not** use Docker.

The goal was to understand:

```text
Git
CI
Build
Artifacts
CD
IAM
EC2
SSM
systemd
Gunicorn
```

first.

Docker/containerization can be added later.

A future architecture could become:

```text
GitHub
   ↓
CodePipeline
   ↓
CodeBuild
   ↓
Docker image
   ↓
ECR
   ↓
EC2 / ECS
```

But that is a separate learning step.

---

# 40. Key Takeaways

### 1. CodePipeline is the orchestrator

It connects:

```text
Source → Build → Deploy
```

### 2. CodeBuild performs the build

It follows:

```text
buildspec.yml
```

### 3. Artifacts move between stages

```text
SourceArtifact
      ↓
BuildArtifact
```

### 4. EC2 is the server

It actually runs the application.

### 5. SSM provides remote command execution

CodePipeline uses SSM to execute deployment operations on the EC2 instance. ([AWS Documentation][1])

### 6. IAM controls access

Each AWS service needs appropriate permissions.

### 7. DeploySpec controls deployment

```text
deployspec.yml
```

defines:

```text
where files go
what happens before deployment
what happens after deployment
```

### 8. systemd keeps the application running

```text
systemd
   ↓
Gunicorn
   ↓
Flask
```

### 9. Always verify the application

A green pipeline is not the only verification.

We also checked:

```bash
systemctl status
```

and:

```bash
curl
```

---

# 41. Final Result

We successfully implemented and verified:

```text
                    CI/CD PIPELINE

GitHub
  │
  │ Push
  ▼
CodePipeline
  │
  ├── Source       ✅
  │
  ├── Build        ✅
  │      │
  │      └── CodeBuild
  │
  └── Deploy       ✅
         │
         └── Amazon EC2
                │
                └── SSM
                      │
                      └── Ubuntu
                            │
                            └── systemd
                                  │
                                  └── Gunicorn
                                        │
                                        └── Flask
                                             │
                                             ▼
                                      Hello, world!
```

**Final status:**

```text
GitHub              ✅
CodePipeline        ✅
CodeBuild           ✅
IAM                 ✅
SSM                 ✅
EC2                 ✅
Deployment          ✅
systemd             ✅
Gunicorn            ✅
Flask               ✅
Application test    ✅
```

This is a solid set of notes to put into your **DevOps learning GitHub repository**. 
<img width="1905" height="788" alt="Screenshot 2026-09-23 165705" src="https://github.com/user-attachments/assets/dd2ebb1b-1484-4b5f-b909-5fe5d639ba54" />
<img width="1905" height="788" alt="Screenshot 2026-09-23 165705" src="https://github.com/user-attachments/assets/5fca4508-4227-4788-bb20-2c599561ba73" />


