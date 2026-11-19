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
2. Check the checkbox next to your `flask-cicd-demo-server` instance
3. Click **Actions** (top right) → **Security** → **Modify IAM role**
4. In the **IAM role** dropdown, select `EC2-SSM-Instance-Role`
5. Click **Update IAM role**

### Verify SSM registered your instance
1. In the AWS Console search bar, type **Systems Manager** and click it
2. In the left sidebar, click **Fleet Manager** (or **Node Management → Fleet Manager** depending on layout)
3. Wait 1-3 minutes, then refresh
4. You should see your instance listed with **Ping status: Online**

If it doesn't appear after a few minutes, connect to the instance
(see below) and check the agent status manually.

### (Optional) Connect to the instance to double-check SSM Agent
1. In EC2 → Instances, check your instance, click **Connect** (top right)
2. Choose the **EC2 Instance Connect** tab, click **Connect** — this opens a browser-based terminal
3. Run: `sudo systemctl status amazon-ssm-agent` (or `sudo snap services amazon-ssm-agent` on newer Ubuntu AMIs with Snap)
4. Confirm it shows **active (running)**

---

## STEP 3 — Create the CodeBuild project

1. In the AWS Console search bar, type **CodeBuild** and click it
2. Click **Create build project**
3. **Project configuration**:
   - Project name: `flask-cicd-demo-build`
4. **Source**:
   - Source provider: select **GitHub** from the dropdown
   - If this is your first time connecting GitHub to this AWS account:
     - Click **Connect using OAuth** (or **Connect with a GitHub personal access token**, whichever option appears)
     - A GitHub window pops up — log in and click **Authorize AWS Connector for GitHub**
   - Repository: select **Repository in my GitHub account**, then choose `flask-cicd-demo` from the dropdown
   - Source version (optional): leave blank or type `master`
5. **Environment**:
   - Environment image: **Managed image**
   - Operating system: **Ubuntu**
   - Runtime(s): **Standard**
   - Image: select the latest `aws/codebuild/standard:8.0` (or whatever is newest)
   - Image version: **Always use the latest image for this runtime version**
   - Environment type: **Linux**
   - Privileged flag checkbox: **leave UNCHECKED** (we're not using Docker)
   - Service role: **New service role** (let it create one automatically) — note the role name shown, you may need it later
6. **Buildspec**:
   - Build specifications: select **Use a buildspec file**
   - Buildspec name: leave blank (it defaults to `buildspec.yml` in the repo root)
7. **Artifacts**: leave as **No artifacts** here — CodePipeline will handle artifact storage separately once connected (CodeBuild run standalone just needs source + output logs)
8. **Logs**: leave CloudWatch Logs checked (default)
9. Click **Create build project**

### Test the CodeBuild project standalone (do this before CodePipeline)
1. On the project page, click **Start build**
2. Leave settings as default, click **Start build** again
3. Watch the phase list on the left: **Submitted → Provisioning → Download source → Install → Pre-build → Build → Post-build → Upload artifacts → Completed**
4. Confirm every phase shows a green checkmark / **Succeeded**
5. If anything fails, click on that phase to see the error in the build log

Do not move to Step 4 until this manual build succeeds.

---

## STEP 4 — Create the CodePipeline

1. In the AWS Console search bar, type **CodePipeline** and click it
2. Click **Create pipeline**
3. **Choose creation option**: select **Build custom pipeline**, click **Next**
4. **Pipeline settings**:
   - Pipeline name: `flask-cicd-demo-pipeline`
   - Pipeline type: select **V2**
   - Execution mode: **Queued**
   - Service role: **New service role** (let AWS create one) — note its name, shown below the selector
5. Click **Next**

### Add source stage
6. **Source provider**: select **GitHub (via GitHub App)** from the dropdown
7. If not already connected, click **Connect to GitHub**, authorize it the same way as Step 3
8. **Repository name**: select `<your-username>/flask-cicd-demo`
9. **Branch name**: select `master`
10. **Change detection options**: leave **Start the pipeline on source code change** checked (this is what enables automatic triggering on `git push`)
11. **Output artifact format**: leave default (CodePipeline default)
12. Click **Next**

### Add build stage
13. **Build provider**: select **AWS CodeBuild**
14. **Region**: should auto-match your account's region
15. **Project name**: select `flask-cicd-demo-build` from the dropdown
16. **Build type**: **Single build**
17. Click **Next**

### Add deploy stage
18. **Deploy provider**: select **Amazon EC2** from the dropdown
19. **Region**: confirm it matches where your EC2 instance lives
20. Under **Target instances**:
    - Select **Tag**
    - Tag key: `Name`
    - Tag value: `flask-cicd-demo-server`
21. **Deployment timeout**: leave default
22. **Deploy spec path**: type exactly `deployspec.yml` (no `.yaml`)
23. Click **Next**

### Review and create
24. Review every stage summary shown on the page
25. Click **Create pipeline**

The pipeline will automatically start its first run immediately after creation.

---

## STEP 5 — Watch the first pipeline run and fix the expected IAM error

1. You'll land on the pipeline's visualization page automatically after creation
2. Watch each stage box: **Source → Build → Deploy**
3. **Source** and **Build** typically succeed on the first try
4. **Deploy** will likely show a red **Failed** badge the first time, with an error like `AccessDeniedException ... logs:PutLogEvents`

### Fix it:
1. In the pipeline page, click **Settings** (top right, near the pipeline name) — or click the pipeline name dropdown and find **Edit** / **Settings**
2. Look for **Service role ARN** — copy the role name part (after the last `/`)
3. In the AWS Console search bar, type **IAM** and click it
4. Click **Roles** in the left sidebar
5. In the search box, paste/type the role name you copied (something like `AWSCodePipelineServiceRole-<region>-flask-cicd-demo-pipeline`)
6. Click on that role
7. Click the **Add permissions** dropdown (top right) → **Create inline policy**
8. Click the **JSON** tab
9. Delete the placeholder text and paste this exact policy:
```json
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
```
10. Click **Next**
11. Policy name: type `EC2DeployPermissions`
12. Click **Create policy**

### Retry the pipeline
1. Go back to the **CodePipeline** console, open `flask-cicd-demo-pipeline`
2. On the failed **Deploy** stage box, click **Retry** (or click **Release change** at the top to rerun the whole pipeline)
3. Watch it run through again — Deploy should now succeed

---

## STEP 6 — Verify the app is actually running

### On the EC2 instance itself
1. Go to **EC2** → **Instances**, select your instance, click **Connect** → **EC2 Instance Connect** → **Connect**
2. In the terminal that opens, run:
   ```
   sudo systemctl status flask-cicd-demo.service
   ```
3. Confirm it shows **Active: active (running)**
4. Run:
   ```
   curl http://localhost:8000
   curl http://localhost:8000/quote
   curl http://localhost:8000/time
   ```
5. Confirm each returns real text, not an error

### From your own browser
1. Go to **EC2** → **Instances**, click on your instance
2. In the details panel below, find and copy **Public IPv4 address**
3. Open a new browser tab and go to:
   ```
   http://<public-ip>:8000
   http://<public-ip>:8000/quote
   http://<public-ip>:8000/time
   ```
4. Confirm each loads correctly

If the browser test fails but the `curl localhost` test on the
instance worked, go back to **EC2 → Security Groups**, open
`flask-cicd-demo-sg`, click **Edit inbound rules**, and confirm the
port 8000 rule exists with source `0.0.0.0/0`.

---

## STEP 7 — Prove the automation works end-to-end

1. On your own computer, edit `app.py` — change the text returned by the `/` route
2. Run in your terminal:
   ```
   git add app.py
   git commit -m "Update home route message"
   git push origin master
   ```
3. Go back to the **CodePipeline** console, open `flask-cicd-demo-pipeline`
4. Within a few seconds to a couple minutes, you should see it automatically start a new run (no button click needed — this is the "Change detection" from Step 4)
5. Watch Source → Build → Deploy all turn green again
6. Refresh `http://<public-ip>:8000` in your browser — it should show your updated text

That confirms the full CI/CD loop: push code → pipeline detects it → builds → deploys → live app updates, with zero manual steps after the initial setup.
