<img width="1868" height="800" alt="Screenshot 2026-09-12 113507" src="https://github.com/user-attachments/assets/0ebc8cfc-1690-4de1-96f6-20a72efd5533" />
<img width="1861" height="828" alt="Screenshot 2026-09-12 113717" src="https://github.com/user-attachments/assets/11b0dbe5-e7d2-4154-8aea-6fd07dfa36f0" />
<img width="1437" height="628" alt="Screenshot 2026-09-12 114057" src="https://github.com/user-attachments/assets/7a1c1768-302b-471b-8cdf-7ff19059511a" />

1. What is Amazon EC2?

EC2 = Elastic Compute Cloud

It provides virtual servers/virtual machines in AWS.

Instead of having a physical server, we create a virtual server in AWS and choose:

Operating system
Instance type
Storage
Network/security settings
Key pair for SSH access

For our learning, we created an Ubuntu EC2 instance.

2. EC2 instance created

We created an:

EC2 Instance
    ↓
Ubuntu Linux
<img width="1430" height="459" alt="Screenshot 2026-09-12 114844" src="https://github.com/user-attachments/assets/3c02f55e-f4a8-4454-88b2-f29a7df46811" />
Our EC2 instance provided us with:

Private IP
Public IP
SSH access
Linux terminal

The EC2 terminal prompt looked like:

ubuntu@ip-172-31-29-2:~$

This tells us that we were connected to the Ubuntu EC2 machine.

3. SSH connection from Windows/WSL

We used WSL on Windows to connect to EC2.

Our .pem key was initially on Windows.

Because Linux requires private SSH keys to have restricted permissions, we copied the key into WSL:

cp /mnt/c/Users/Vi39060Po/EC2_login.pem ~/EC2_login.pem

Then changed its permissions:

chmod 400 ~/EC2_login.pem

Then connected to EC2:

ssh -i ~/EC2_login.pem ubuntu@<EC2-PUBLIC-IP>
Important

We learned:

Windows
   ↓
WSL
   ↓ SSH
EC2 Ubuntu
4. Installed Jenkins on EC2

We installed Jenkins on the Ubuntu EC2 server.

Jenkins is a CI/CD automation server.

The architecture became:

Windows Browser
       ↓
Internet
       ↓
AWS EC2
       ↓
Ubuntu Linux
       ↓
Jenkins
       ↓
Port 8080
5. Jenkins initially failed

When we first tried to start Jenkins, it failed.

The important error was:

Running with Java 11
Minimum required version: Java 21

So the problem was:

Jenkins
   ↓
Java 11 ❌

Jenkins required a newer Java version.

6. Installed Java 21

We installed Java 21:

sudo apt update
sudo apt install -y fontconfig openjdk-21-jre

Then checked:

java -version

It showed Java 21.

We also checked the available Java versions using:

sudo update-alternatives --config java

Java 21 was selected as the default.

7. Jenkins was still using Java 11

Even though our normal terminal was using Java 21, Jenkins' systemd service was still starting with Java 11.

So we created a systemd override.

Command:

sudo systemctl edit jenkins

We added:

[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"

Then:

sudo systemctl daemon-reload

and:

sudo systemctl restart jenkins
8. Verified Jenkins

We checked:

sudo systemctl status jenkins --no-pager

and got:

Active: active (running)

We also confirmed Jenkins was actually using Java 21:

/usr/lib/jvm/java-21-openjdk-amd64/bin/java

So:

Jenkins
   ↓
Java 21
   ↓
Running successfully ✅
9. Checked Jenkins port

Jenkins normally runs on:

Port 8080

We checked:

sudo ss -lntp | grep 8080

and got:

LISTEN ... *:8080

This confirmed Jenkins was listening on port 8080.

10. Tested Jenkins locally

Inside EC2 we ran:

curl -I http://localhost:8080

We received:

HTTP/1.1 403 Forbidden

At first this might look like an error, but it actually proved that Jenkins was responding.

The request was simply unauthenticated.

11. Accessed Jenkins from browser

We opened:

http://<EC2-PUBLIC-IP>:8080

and reached:

Unlock Jenkins

This confirmed:

Browser
   ↓
EC2 Public IP
   ↓
Port 8080
   ↓
Jenkins
12. Jenkins initial setup

Jenkins showed the initial administrator password location:

/var/lib/jenkins/secrets/initialAdminPassword

We could retrieve it from EC2 with:

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
<img width="1591" height="868" alt="Screenshot 2026-09-12 120451" src="https://github.com/user-attachments/assets/d6aa1d16-76ff-4c43-8c12-95dc10439849" />
We then unlocked Jenkins.

Next we reached:

Customize Jenkins

We selected:

Install suggested plugins
<img width="1760" height="911" alt="Screenshot 2026-09-12 120546" src="https://github.com/user-attachments/assets/9d86d59a-202b-4309-880c-ba648b6939cc" />

This installs commonly useful Jenkins plugins for a beginner setup.
