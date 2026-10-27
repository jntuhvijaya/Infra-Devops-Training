# Terraform Learning Notes — Day 1

## 1. Objective

Learn Terraform fundamentals and prepare a Windows environment for Infrastructure as Code (IaC) practical exercises using AWS.

## 2. What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool developed by HashiCorp. It allows us to create, update, manage, and delete infrastructure using configuration files written in HCL (HashiCorp Configuration Language).

Examples of infrastructure managed by Terraform:
- AWS EC2 instances
- S3 buckets
- VPCs and subnets
- Security groups
- Databases
- Azure and Google Cloud resources

## 3. Tools required

| Tool | Purpose | Status |
|---|---|---|
| Visual Studio Code | Write Terraform configuration files | Installed |
| Terraform CLI | Execute Terraform commands | Installation required / to verify |
| AWS CLI | Authenticate and interact with AWS | Installation required / to verify |
| AWS account | Host AWS infrastructure | To configure |

## 4. My working directory

Windows PowerShell project directory:

```powershell
cd "C:\Users\Vi39060Po\OneDrive - Prolifics Corporation Ltd.,\InfraDevops_Training\terraform"
```

## 5. Environment verification

Commands executed:

```powershell
terraform --version
aws --version
code --version
```

Results:
- `terraform --version` — command not recognized.
- `aws --version` — command not recognized.
- `code --version` — successful; VS Code version 1.141.0.

### Issue identified

Terraform CLI and AWS CLI were either not installed or were not available through the Windows PATH environment variable.

### Installation commands

If Windows Package Manager (`winget`) is available:

```powershell
winget --version
winget install --id Hashicorp.Terraform -e
winget install --id Amazon.AWSCLI -e
```

Official installation resources:

- Terraform: https://developer.hashicorp.com/terraform/install
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

After installation, restart the terminal and verify:

```powershell
terraform --version
aws --version
code --version
```

## 6. Terraform workflow

The standard workflow is:

1. Write Terraform configuration files.
2. Run `terraform init` to initialize the working directory and download providers.
3. Run `terraform fmt` to format the files.
4. Run `terraform validate` to validate the configuration.
5. Run `terraform plan` to preview infrastructure changes.
6. Run `terraform apply` to apply the reviewed changes.
7. Run `terraform output` to display configured outputs.
8. Run `terraform destroy` to remove practice infrastructure when appropriate.

## 7. Important Terraform commands

| Command | Purpose |
|---|---|
| `terraform --version` | Check Terraform installation |
| `terraform init` | Initialize project |
| `terraform fmt` | Format Terraform files |
| `terraform fmt -check` | Check formatting |
| `terraform validate` | Validate configuration |
| `terraform plan` | Preview proposed changes |
| `terraform apply` | Create or update infrastructure |
| `terraform output` | Display outputs |
| `terraform state list` | List resources tracked in state |
| `terraform show` | Inspect current state or a saved plan |
| `terraform destroy` | Remove managed infrastructure |
| `aws --version` | Check AWS CLI installation |
| `aws sts get-caller-identity` | Verify AWS identity |

## 8. Terraform configuration files

A typical Terraform project can be organized as follows:

```text
terraform/
├── versions.tf
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── .gitignore
└── .terraform.lock.hcl
```

File responsibilities:

- `versions.tf`: Terraform and provider version requirements.
- `provider.tf`: Cloud provider configuration.
- `main.tf`: Infrastructure resource definitions.
- `variables.tf`: Input variable declarations.
- `outputs.tf`: Values displayed after applying configuration.
- `terraform.tfvars`: Values assigned to variables.
- `.gitignore`: Files that should not be committed to Git.
- `.terraform.lock.hcl`: Records selected provider versions and checksums.

These filenames are conventions and can be organized differently.

## 9. Core Terraform concepts

### Provider
A plugin that enables Terraform to interact with a platform, such as AWS.

### Resource
An infrastructure object that Terraform manages, such as an S3 bucket.

### Variable
An input value that makes configuration reusable.

### Output
A value Terraform displays after applying configuration.

### State
Records the relationship between Terraform configuration and managed infrastructure.

### Module
A reusable collection of Terraform configuration files.

### Plan
A preview of proposed infrastructure changes before they are applied.

## 10. Planned practical project: AWS S3 bucket

The first hands-on exercise is to create an S3 bucket using Terraform.

Planned resources:

- An S3 bucket with a generated name.
- A public-access block to help prevent accidental public exposure.
- Tags for project and environment identification.
- Outputs for the bucket name and ARN.

Before applying the configuration:

1. Confirm Terraform is installed.
2. Confirm AWS CLI is installed.
3. Configure approved AWS credentials or SSO.
4. Verify the AWS identity.
5. Initialize and validate the Terraform project.
6. Review the execution plan.

Useful AWS verification command:

```powershell
aws sts get-caller-identity
```

## 11. GitHub tracking and security

Recommended repository structure:

```text
terraform-learning/
├── README.md
├── notes/
│   └── day-01-terraform-basics.md
├── exercises/
│   └── s3-bucket/
│       ├── versions.tf
│       ├── provider.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── .gitignore
└── .gitignore
```

Important files to exclude:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
terraform.tfvars
*.tfvars
!example.tfvars
crash.log
crash.*.log
```

<img width="1867" height="875" alt="Screenshot 2026-10-27 142745" src="https://github.com/user-attachments/assets/909bcc6f-39f2-4d2a-8636-a4e9fb5d25ec" />
<img width="1821" height="917" alt="Screenshot 2026-10-27 142734" src="https://github.com/user-attachments/assets/113ba148-4173-46d1-bb4b-67b74fa036d8" />
<img width="1595" height="974" alt="Screenshot 2026-10-27 142723" src="https://github.com/user-attachments/assets/88fdd1f0-3d84-43bb-a4ca-1674639833c0" />
<img width="1847" height="935" alt="Screenshot 2026-10-27 142711" src="https://github.com/user-attachments/assets/af60f40b-ba3e-4997-99fa-d805846c0c7a" />
<img width="1818" height="866" alt="Screenshot 2026-10-27 142651" src="https://github.com/user-attachments/assets/68936eea-c4aa-4db5-936b-1519eca3827b" />
<img width="1901" height="484" alt="Screenshot 2026-10-27 142304" src="https://github.com/user-attachments/assets/1bd3e4ac-07e4-4132-a921-640f64ca6cb7" />


