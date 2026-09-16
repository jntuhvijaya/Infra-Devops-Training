## 1. What is Amazon S3?

**S3 = Simple Storage Service**

Amazon S3 is an AWS service used to **store and retrieve files/data over the internet**.

Think of S3 like a **cloud storage system**, but designed for applications and large-scale data.

Examples of things you can store:

* HTML files
* Images
* Videos
* PDFs
* Backups
* Log files
* Application files
* Database backups
* Data for websites/applications

AWS describes S3 as an **object storage service**. Data is stored as objects inside buckets. ([AWS Documentation][1])

---

# 2. Simple Example

Suppose you have:

```text
index.html
image.jpg
resume.pdf
backup.zip
```

Instead of storing these files only on your laptop, you can upload them to S3.

```text
AWS Account
     |
     └── S3
          |
          └── Bucket
               |
               ├── index.html
               ├── image.jpg
               ├── resume.pdf
               └── backup.zip
```

---

# 3. Important S3 Terminology

There are three terms you should remember:

### Bucket

A **bucket is a container for storing objects**.

Think:

> Bucket = Folder/container in the cloud

Example:

```text
my-devops-learning-bucket
```

A bucket can contain many objects.

---

### Object

An **object is the actual file/data stored in S3**.

Example:

```text
index.html
photo.jpg
backup.zip
```

AWS calls the stored file an **object**. An object contains the file's data plus metadata. ([AWS Documentation][1])

---

### Object Key

The **object key** is basically the name/path used to identify an object.

Example:

```text
index.html
images/aws-logo.png
backup/database.zip
```

So:

```text
Bucket
   |
   ├── index.html
   ├── images/
   │     └── aws-logo.png
   └── backup/
         └── database.zip
```

The key for the image can be:

```text
images/aws-logo.png
```

---

# 4. S3 vs EC2

This is important for your DevOps learning.

| EC2                       | S3                                     |
| ------------------------- | -------------------------------------- |
| Virtual server            | Object storage                         |
| Used to run applications  | Used to store files/data               |
| Has CPU/RAM               | Doesn't work like a traditional server |
| Can install Linux/Windows | Store objects/files                    |
| You manage the OS         | AWS manages the storage infrastructure |
| Example: web server       | Example: images/backups                |

### Simple example

Your architecture could be:

```text
User
  |
  ↓
Application on EC2
  |
  ↓
S3
  |
  ├── Images
  ├── Documents
  └── Backups
```

---

# 5. Creating an S3 Bucket

Basic flow:

```text
AWS Console
    ↓
S3
    ↓
Create bucket
    ↓
Give bucket name
    ↓
Choose AWS Region
    ↓
Configure settings
    ↓
Create bucket
```

Bucket names must be globally unique.

For example:

```text
vijaya-devops-learning-2026
```

If that name is already taken by another AWS customer, you need another name.

---

# 6. Uploading a File

After creating a bucket:

```text
S3
 ↓
Bucket
 ↓
Upload
 ↓
Add files
 ↓
Choose file
 ↓
Upload
```

For example:

```text
vijaya-devops-learning-2026
       |
       ├── index.html
       └── image.png
```

---

# 7. Downloading a File

You can download an object from S3:

```text
S3
 ↓
Bucket
 ↓
Select object
 ↓
Download
```

S3 supports uploading, downloading, copying and deleting objects. ([AWS Documentation][1])

---

# 8. S3 Storage Classes

S3 provides different **storage classes** depending on how frequently you access your data. ([AWS Documentation][2])

Important ones for beginners:

### S3 Standard

For frequently accessed data.

Example:

```text
Website images
Application files
Frequently used documents
```

This is the default storage class for general-purpose S3 buckets. ([AWS Documentation][2])

---

### S3 Standard-IA

IA = **Infrequent Access**

Used when you don't access the data frequently but still need relatively quick access.

Example:

```text
Monthly reports
Older files
Backups that may occasionally be needed
```

---

### S3 Intelligent-Tiering

Useful when you **don't know how frequently your data will be accessed**.

S3 can automatically move objects between access tiers based on access patterns. ([AWS Documentation][2])

---

### S3 Glacier

Used mainly for **archiving**.

Example:

```text
Old backups
Historical records
Compliance data
```

Think:

> Glacier = Long-term archive

---

### S3 Glacier Deep Archive

For data that is rarely accessed and needs long-term archival storage.

Example:

```text
7-year-old company records
Long-term backups
Historical data
```

---

# 9. S3 Versioning

**Versioning** allows S3 to keep multiple versions of an object.

Suppose you upload:

```text
index.html
```

Then modify it and upload it again.

Without versioning:

```text
index.html → latest version
```

With versioning:

```text
index.html
   |
   ├── Version 1
   ├── Version 2
   └── Version 3
```

This helps recover from accidental overwrites or deletions. ([AWS Documentation][3])

### Example

You accidentally replace:

```text
website.html
```

Versioning can allow you to retrieve the previous version.

---

# 10. S3 Lifecycle

**Lifecycle rules** automatically manage objects as they age.

For example:

```text
Day 0
 ↓
S3 Standard

After 30 days
 ↓
S3 Standard-IA

After 90 days
 ↓
Glacier

After 365 days
 ↓
Delete
```

Lifecycle rules can transition objects to different storage classes or automatically delete objects when they expire. ([AWS Documentation][4])

This is useful for **cost management**.

---

# 11. S3 Security

This is VERY important.

By default, AWS recommends keeping **Block Public Access enabled** unless you specifically need public access. ([AWS Documentation][1])

S3 access can involve:

* IAM permissions
* Bucket policies
* Block Public Access
* Encryption
* Versioning
* Object Lock

### Simple example

You might have:

```text
Private S3 Bucket
       |
       ├── company.pdf
       ├── backup.zip
       └── database.sql
```

Only authorized users/applications should access these files.

---

# 12. S3 Encryption

S3 automatically encrypts new objects at rest using **SSE-S3** by default. ([AWS Documentation][5])

Common encryption options include:

```text
SSE-S3
   ↓
AWS-managed S3 encryption

SSE-KMS
   ↓
AWS Key Management Service

Client-side encryption
   ↓
You encrypt before uploading
```

For your beginner AWS learning, remember:

> **S3 encrypts new objects by default.**

---

# 13. S3 Bucket Policy

A **bucket policy** is a JSON-based policy attached to a bucket.

It controls who can perform actions on the bucket/objects.

Example actions:

```text
s3:GetObject
s3:PutObject
s3:DeleteObject
```

For example:

```text
User/Application
       |
       ↓
Bucket Policy
       |
       ↓
S3 Bucket
```

---

# 14. IAM + S3

IAM controls **who is allowed to access S3**.

For example:

```text
IAM User
   |
   ↓
Permission
   |
   ↓
S3 Bucket
```

A user could have permission to:

```text
Read → YES
Upload → YES
Delete → NO
```

This is called **least privilege**: give only the permissions that are actually required.

---

# 15. S3 Static Website Hosting

S3 can also be used to host a **static website**.

For example:

```text
index.html
style.css
script.js
images/
```

can be stored in S3.

Architecture:

```text
User
  |
  ↓
S3
  |
  ├── index.html
  ├── style.css
  ├── script.js
  └── images/
```

For production websites, AWS commonly recommends using **CloudFront with S3** for content delivery and security.

---

# 16. S3 and Your Current AWS Learning

You are currently learning:

```text
EC2
 ↓
Load Balancer
 ↓
Target Group
 ↓
Application
```

S3 is another important building block.

A larger architecture can look like:

```text
                 User
                   |
                   ↓
              Load Balancer
                   |
                   ↓
             EC2 Application
              /           \
             /             \
            ↓               ↓
          S3              Database
       Files/Images          |
       Backups               |
```

For example, your EC2 application could store uploaded images in S3 rather than keeping them on the EC2 server.

---

# 17. S3 CLI Commands

Once you start using AWS CLI, these commands are important.

### List buckets

```bash
aws s3 ls
```

### Create bucket

Example:

```bash
aws s3 mb s3://my-devops-learning-bucket
```

### Upload file

```bash
aws s3 cp index.html s3://my-devops-learning-bucket/
```

### List files

```bash
aws s3 ls s3://my-devops-learning-bucket/
```

### Download file

```bash
aws s3 cp s3://my-devops-learning-bucket/index.html .
```

### Upload folder

```bash
aws s3 cp myfolder/ s3://my-devops-learning-bucket/myfolder/ --recursive
```

### Delete file

```bash
aws s3 rm s3://my-devops-learning-bucket/index.html
```

### Delete bucket

```bash
aws s3 rb s3://my-devops-learning-bucket
```

If the bucket contains objects, you generally need to remove the objects first.

---

# 18. S3 Important Features — Quick Revision

| Feature                 | Meaning                                   |
| ----------------------- | ----------------------------------------- |
| **Bucket**              | Container for objects                     |
| **Object**              | File/data stored in S3                    |
| **Object Key**          | Name/path of an object                    |
| **Versioning**          | Keeps previous versions                   |
| **Lifecycle**           | Automatically moves/deletes objects       |
| **Storage Classes**     | Different options based on access pattern |
| **Bucket Policy**       | Controls bucket access                    |
| **IAM**                 | Controls user/role permissions            |
| **Encryption**          | Protects stored data                      |
| **Block Public Access** | Helps prevent unintended public access    |
| **Object Lock**         | Protects objects from deletion/overwrite  |
| **Replication**         | Copies objects to another bucket/Region   |

---
<img width="1847" height="711" alt="Screenshot 2026-09-16 140337" src="https://github.com/user-attachments/assets/7320e532-6a17-4fbf-a382-418226ab6251" />
<img width="1497" height="657" alt="Screenshot 2026-09-16 140350" src="https://github.com/user-attachments/assets/b5501ef9-6f75-47f4-a76a-c5a3e04bc5b1" />


