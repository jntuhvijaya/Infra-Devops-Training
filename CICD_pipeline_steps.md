
Previewing AWS_CONSOLE_EXACT_STEPS.md
# AWS Console — Exact Click-by-Click Steps

This is the pure "where do I click" guide — no code here (that's in
`CICD_COMPLETE_WALKTHROUGH.md` and the `flask-cicd-demo/` files).
Follow this in order, in the AWS Console, after you've already
pushed `flask-cicd-demo` to GitHub.

---

## STEP 1 — Launch the EC2 instance

1. In the AWS Console search bar (top), type **EC2** and click it
2. On the EC2 dashboard, click the orange **Launch instance** button
3. Under **Name and tags**:
   - In the **Name** field, type: `flask-cicd-demo-server`
4. Under **Application and OS Images (Amazon Machine Image)**:
   - Click the **Ubuntu** tile
   - In the dropdown below it, leave the default Ubuntu LTS version selected
   - Confirm it says **Free tier eligible** somewhere near it
5. Under **Instance type**:
   - Select **t3.micro** from the dropdown (confirm "Free tier eligible" label next to it)
6. Under **Key pair (login)**:
   - Click **Create new key pair**
   - Key pair name: `flask-cicd-demo-key`
   - Key pair type: RSA
   - Private key file format: `.pem` (Mac/Linux) or `.ppk` (if you'll use PuTTY on Windows)
   - Click **Create key pair** — this downloads a file. Save it somewhere safe; you can't download it again
7. Under **Network settings**, click **Edit**:
   - **VPC**: leave default
   - **Subnet**: leave default (no preference)
   - **Auto-assign public IP**: **Enable**
   - **Firewall (security groups)**: select **Create security group**
   - Security group name: `flask-cicd-demo-sg`
   - It will show one default rule (SSH, port 22, source "My IP" or "Anywhere") — leave SSH as is, or set source to **My IP** for better security
   - Click **Add security group rule**:
     - Type: **Custom TCP**
     - Port range: `8000`
     - Source type: **Anywhere** (0.0.0.0/0)
     - Description (optional): `Flask app access`
8. Under **Configure storage**: leave the default (8 GiB gp3 is fine)
9. Scroll down, review the **Summary** panel on the right
10. Click the orange **Launch instance** button
11. Click **View all instances** to go back to the instance list
12. Wait until the **Instance state** column shows **Running** and **Status check** shows **2/2 checks passed** (takes 1-2 minutes)

---

## STEP 2 — Create the IAM role for SSM

1. In the AWS Console search bar, type **IAM** and click it
2. In the left sidebar, click **Roles**
3. Click the orange **Create role** button
4. Under **Trusted entity type**, select **AWS service** (should be selected by default)
5. Under **Use case**, select **EC2** from the dropdown, then click **EC2** radio option that appears below it
6. Click **Next**
7. In the **Permissions policies** search box, type: `AmazonSSMManagedInstanceCore`
8. Check the checkbox next to that policy
9. Click **Next**
10. **Role name**: type `EC2-SSM-Instance-Role`
11. Scroll down, review, click **Create role**

### Attach the role to your EC2 instance
1. Go back to **EC2** → **Instances**
AWS Console — Exact Click-by-Click Steps
This is the pure "where do I click" guide — no code here (that's in CICD_COMPLETE_WALKTHROUGH.md and the flask-cicd-demo/ files). Follow this in order, in the AWS Console, after you've already pushed flask-cicd-demo to GitHub.

STEP 1 — Launch the EC2 instance
In the AWS Console search bar (top), type EC2 and click it
On the EC2 dashboard, click the orange Launch instance button
Under Name and tags:
In the Name field, type: flask-cicd-demo-server
Under Application and OS Images (Amazon Machine Image):
Click the Ubuntu tile
In the dropdown below it, leave the default Ubuntu LTS version selected
Confirm it says Free tier eligible somewhere near it
Under Instance type:
Select t3.micro from the dropdown (confirm "Free tier eligible" label next to it)
Under Key pair (login):
Click Create new key pair
Key pair name: flask-cicd-demo-key
Key pair type: RSA
Private key file format: .pem (Mac/Linux) or .ppk (if you'll use PuTTY on Windows)
Click Create key pair — this downloads a file. Save it somewhere safe; you can't download it again
Under Network settings, click Edit:
VPC: leave default
Subnet: leave default (no preference)
Auto-assign public IP: Enable
Firewall (security groups): select Create security group
Security group name: flask-cicd-demo-sg
It will show one default rule (SSH, port 22, source "My IP" or "Anywhere") — leave SSH as is, or set source to My IP for better security
Click Add security group rule:
Type: Custom TCP
Port range: 8000
Source type: Anywhere (0.0.0.0/0)
Description (optional): Flask app access
Under Configure storage: leave the default (8 GiB gp3 is fine)
Scroll down, review the Summary panel on the right
Click the orange Launch instance button
Click View all instances to go back to the instance list
Wait until the Instance state column shows Running and Status check shows 2/2 checks passed (takes 1-2 minutes)
STEP 2 — Create the IAM role for SSM
In the AWS Console search bar, type IAM and click it
In the left sidebar, click Roles
Click the orange Create role button
Under Trusted entity type, select AWS service (should be selected by default)
Under Use case, select EC2 from the dropdown, then click EC2 radio option that appears below it
Click Next
In the Permissions policies search box, type: AmazonSSMManagedInstanceCore
Check the checkbox next to that policy
Click Next
Role name: type EC2-SSM-Instance-Role
Scroll down, review, click Create role
Attach the role to your EC2 instance
Go back to EC2 → Instances
Check the checkbox next to your flask-cicd-demo-server instance
Click Actions (top right) → Security → Modify IAM role
In the IAM role dropdown, select EC2-SSM-Instance-Role
Click Update IAM role
Verify SSM registered your instance
In the AWS Console search bar, type Systems Manager and click it
In the left sidebar, click Fleet Manager (or Node Management → Fleet Manager depending on layout)
Wait 1-3 minutes, then refresh
You should see your instance listed with Ping status: Online
If it doesn't appear after a few minutes, connect to the instance (see below) and check the agent status manually.

(Optional) Connect to the instance to double-check SSM Agent
In EC2 → Instances, check your instance, click Connect (top right)
Choose the EC2 Instance Connect tab, click Connect — this opens a browser-based terminal
Run: sudo systemctl status amazon-ssm-agent (or sudo snap services amazon-ssm-agent on newer Ubuntu AMIs with Snap)
Confirm it shows active (running)
STEP 3 — Create the CodeBuild project
In the AWS Console search bar, type CodeBuild and click it
Click Create build project
Project configuration:
Project name: flask-cicd-demo-build
Source:
Source provider: select GitHub from the dropdown
If this is your first time connecting GitHub to this AWS account:
Click Connect using OAuth (or Connect with a GitHub personal access token, whichever option appears)
A GitHub window pops up — log in and click Authorize AWS Connector for GitHub
Repository: select Repository in my GitHub account, then choose flask-cicd-demo from the dropdown
Source version (optional): leave blank or type master
Environment:
Environment image: Managed image
Operating system: Ubuntu
Runtime(s): Standard
Image: select the latest aws/codebuild/standard:8.0 (or whatever is newest)
Image version: Always use the latest image for this runtime version
Environment type: Linux
Privileged flag checkbox: leave UNCHECKED (we're not using Docker)
Service role: New service role (let it create one automatically) — note the role name shown, you may need it later
Buildspec:
Build specifications: select Use a buildspec file
Buildspec name: leave blank (it defaults to buildspec.yml in the repo root)
Artifacts: leave as No artifacts here — CodePipeline will handle artifact storage separately once connected (CodeBuild run standalone just needs source + output logs)
Logs: leave CloudWatch Logs checked (default)
Click Create build project
Test the CodeBuild project standalone (do this before CodePipeline)
On the project page, click Start build
Leave settings as default, click Start build again
Watch the phase list on the left: Submitted → Provisioning → Download source → Install → Pre-build → Build → Post-build → Upload artifacts → Completed
Confirm every phase shows a green checkmark / Succeeded
If anything fails, click on that phase to see the error in the build log
Do not move to Step 4 until this manual build succeeds.

STEP 4 — Create the CodePipeline
In the AWS Console search bar, type CodePipeline and click it
Click Create pipeline
Choose creation option: select Build custom pipeline, click Next
Pipeline settings:
Pipeline name: flask-cicd-demo-pipeline
Pipeline type: select V2
Execution mode: Queued
Service role: New service role (let AWS create one) — note its name, shown below the selector
Click Next
Add source stage
Source provider: select GitHub (via GitHub App) from the dropdown
If not already connected, click Connect to GitHub, authorize it the same way as Step 3
Repository name: select <your-username>/flask-cicd-demo
Branch name: select master
Change detection options: leave Start the pipeline on source code change checked (this is what enables automatic triggering on git push)
Output artifact format: leave default (CodePipeline default)
Click Next
Add build stage
Build provider: select AWS CodeBuild
Region: should auto-match your account's region
Project name: select flask-cicd-demo-build from the dropdown
Build type: Single build
Click Next
Add deploy stage
Deploy provider: select Amazon EC2 from the dropdown
Region: confirm it matches where your EC2 instance lives
Under Target instances:
Select Tag
Tag key: Name
Tag value: flask-cicd-demo-server
Deployment timeout: leave default
Deploy spec path: type exactly deployspec.yml (no .yaml)
Click Next
Review and create
Review every stage summary shown on the page
Click Create pipeline
The pipeline will automatically start its first run immediately after creation.

STEP 5 — Watch the first pipeline run and fix the expected IAM error
You'll land on the pipeline's visualization page automatically after creation
Watch each stage box: Source → Build → Deploy
Source and Build typically succeed on the first try
Deploy will likely show a red Failed badge the first time, with an error like AccessDeniedException ... logs:PutLogEvents
Fix it:
In the pipeline page, click Settings (top right, near the pipeline name) — or click the pipeline name dropdown and find Edit / Settings
Look for Service role ARN — copy the role name part (after the last /)
In the AWS Console search bar, type IAM and click it
Click Roles in the left sidebar
In the search box, paste/type the role name you copied (something like AWSCodePipelineServiceRole-<region>-flask-cicd-demo-pipeline)
Click on that role
Click the Add permissions dropdown (top right) → Create inline policy
Click the JSON tab
Delete the placeholder text and paste this exact policy:
json
Copy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ssm:CancelCommand",
        "ssm:DescribeInstanceInformation",
        "ssm:ListCommandInvocations",
        "ssm:SendCommand",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
Click Next
Policy name: type EC2DeployPermissions
Click Create policy
Retry the pipeline
Go back to the CodePipeline console, open flask-cicd-demo-pipeline
On the failed Deploy stage box, click Retry (or click Release change at the top to rerun the whole pipeline)
Watch it run through again — Deploy should now succeed
STEP 6 — Verify the app is actually running
On the EC2 instance itself
Go to EC2 → Instances, select your instance, click Connect → EC2 Instance Connect → Connect
In the terminal that opens, run:
Copy
sudo systemctl status flask-cicd-demo.service
Confirm it shows Active: active (running)
Run:
Copy
curl http://localhost:8000
curl http://localhost:8000/quote
curl http://localhost:8000/time
Confirm each returns real text, not an error
From your own browser
Go to EC2 → Instances, click on your instance
In the details panel below, find and copy Public IPv4 address
Open a new browser tab and go to:
Copy
http://<public-ip>:8000
http://<public-ip>:8000/quote
http://<public-ip>:8000/time
Confirm each loads correctly
If the browser test fails but the curl localhost test on the instance worked, go back to EC2 → Security Groups, open flask-cicd-demo-sg, click Edit inbound rules, and confirm the port 8000 rule exists with source 0.0.0.0/0.

STEP 7 — Prove the automation works end-to-end
On your own computer, edit app.py — change the text returned by the / route
Run in your terminal:
Copy
git add app.py
git commit -m "Update home route message"
git push origin master
Go back to the CodePipeline console, open flask-cicd-demo-pipeline
Within a few seconds to a couple minutes, you should see it automatically start a new run (no button click needed — this is the "Change detection" from Step 4)
Watch Source → Build → Deploy all turn green again
Refresh http://<public-ip>:8000 in your browser — it should show your updated text
That confirms the full CI/CD loop: push code → pipeline detects it → builds → deploys → live app updates, with zero manual steps after the initial setup.

