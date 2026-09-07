# AWS — Creating Your Free Account + Core Fundamentals

---

## Part 1: Creating Your AWS Account (Current 2026 Process)

**Important:** AWS changed its signup process on July 15, 2025. Most
tutorials online still describe the *old* "12 months free" system,
which no longer applies to new accounts. Here's what you'll actually
see today.

### What changed
- **Old system (before July 2025):** 12 months of free usage on
  specific services, automatically.
- **New system (accounts created now):** You choose between a
  **Free Plan** or a **Paid Plan** during signup. Both start with
  **$100 in credit** immediately, and you can earn up to **$100 more**
  (total $200) by completing 5 short onboarding tasks.
- The **Free Plan** lasts **6 months** or until your credits run out,
  whichever happens first. After that, you get a 90-day grace period
  to upgrade to Paid before the account and its resources are removed.
- Over **30 "Always Free" services** (with permanent monthly limits,
  regardless of plan) still exist separately from this credit system
  — things like a small amount of Lambda usage, DynamoDB storage, etc.

### What you'll need before starting
- A valid email address
- A phone number (for verification)
- A debit/credit card (required even for the Free Plan — you won't be
  charged automatically, but AWS uses it to verify identity)
- About 15-20 minutes

### Step-by-step signup

1. Go to **aws.amazon.com** and click **"Create an AWS Account"**
2. Enter your email address and choose an **account name** (this is
   just a label, e.g. "Vijaya-Training")
3. Check your email for a verification code, enter it to confirm
4. Create a strong **root user password** — this account has FULL
   access to everything, so treat this password seriously
5. Fill in contact information (name, phone, address)
6. Enter payment card details (required, but not charged for Free Plan usage)
7. Verify your phone number via SMS or call
8. **Choose your plan:**
   - **Free Plan** — recommended for you right now: learning/exploring, $100-$200 credit, 6-month cap, some expensive/enterprise services are blocked so you can't accidentally rack up huge bills
   - **Paid Plan** — for production use, full service access, standard pay-as-you-go pricing
9. Select the **Basic Support Plan (Free)**
10. Done — AWS will confirm activation (can take a few minutes to an hour)

### CRITICAL first steps after your account is created

Do these **immediately**, before touching any actual AWS services:

1. **Enable MFA (Multi-Factor Authentication) on your root account.**
   Use an app like Google Authenticator or Authy. This is your most
   important security step — the root account can do anything,
   including delete your whole account.
2. **Set up a billing alert/budget.** Go to **AWS Budgets** and set a
   $1 or $5 alert so you get emailed the moment anything starts costing
   money — this is also one of the 5 tasks that earns you extra credit.
3. **Create an IAM user for daily use — stop logging in as root.**
   The root account should be used only for account-level tasks (like
   billing). For everyday work, create a separate IAM user with
   limited permissions. (More on IAM below.)
4. **Pick your AWS Region** (e.g., `ap-south-1` for Mumbai, close to
   Hyderabad) — most resources you create are tied to whichever
   region you're currently viewing in the console.

---

## Part 2: AWS Fundamentals — Core Concepts

### What is "the cloud", actually?

Instead of buying and maintaining your own physical servers, you rent
computing resources (servers, storage, databases, networking) from a
company like AWS, over the internet, and pay only for what you use.

### Regions and Availability Zones

- A **Region** is a physical geographic area (e.g., Mumbai, N. Virginia, Singapore) — AWS has data centers there.
- Each Region contains multiple **Availability Zones (AZs)** — physically separate data centers within that region, connected by fast, low-latency links.
- **Why this matters:** spreading your application across multiple AZs means if one data center has a power outage or fire, your app keeps running from another.

```
Region: ap-south-1 (Mumbai)
    ├── Availability Zone: ap-south-1a
    ├── Availability Zone: ap-south-1b
    └── Availability Zone: ap-south-1c
```

### The core services you'll hear about constantly

| Service | What it is | Plain-English analogy |
|---|---|---|
| **EC2** (Elastic Compute Cloud) | Virtual servers you rent | Renting a computer in someone else's data center |
| **S3** (Simple Storage Service) | Object/file storage | An infinitely large online filing cabinet |
| **IAM** (Identity and Access Management) | Controls who can do what | The security guard checking ID badges and permission levels |
| **VPC** (Virtual Private Cloud) | Your own isolated network inside AWS | Your own private section of the building, walled off from other tenants |
| **RDS** (Relational Database Service) | Managed databases (MySQL, PostgreSQL, etc.) | A database that AWS maintains/patches/backs up for you |
| **Lambda** | Run code without managing a server at all | Paying someone to run your errand exactly when needed, instead of keeping staff on payroll 24/7 |
| **CloudWatch** | Monitoring and logging | The building's security camera + alarm system |
| **Route 53** | DNS service (domain names → IP addresses) | The phonebook, translating names into addresses |
| **ELB** (Elastic Load Balancer) | Distributes traffic across multiple servers | A receptionist directing visitors to whichever available desk |

---

## Part 3: Networking & Security Concepts (Deep Dive)

### VPC (Virtual Private Cloud) — your private network

When you use AWS, your resources (servers, databases) live inside a
**VPC** — your own isolated slice of the AWS network, which you
control. Inside a VPC, you create:

- **Subnets** — smaller sub-divisions of your VPC's IP address range, tied to a specific Availability Zone
  - **Public subnet** — has a route to the internet (for things like a website's front-end server)
  - **Private subnet** — no direct internet access (for things like a database, which should never be directly reachable from outside)
- **Route tables** — rules that decide where network traffic is allowed to go
- **Internet Gateway** — the "door" that connects a VPC to the public internet

```
VPC (your private network, e.g. 10.0.0.0/16)
    ├── Public Subnet (10.0.1.0/24)  → has internet access → web servers here
    └── Private Subnet (10.0.2.0/24) → NO internet access  → databases here
```

### "Firewall" in AWS — Security Groups and NACLs

AWS doesn't have one single thing literally called "a firewall" — it
splits that job into two layers:

**1. Security Groups** (the one you'll use most often)
- Acts like a firewall attached directly to an individual resource (e.g., one EC2 server)
- **Stateful** — if you allow incoming traffic on a rule, the matching outgoing reply is automatically allowed too, no need to write a separate rule for it
- You write rules like: "allow incoming traffic on port 22 (SSH) only from my IP address" or "allow incoming traffic on port 443 (HTTPS) from anywhere"
- Default behavior: **deny everything**, until you explicitly allow something

**2. Network ACLs (NACLs)**
- Acts like a firewall attached to an entire **subnet** (not a single server)
- **Stateless** — you must write separate rules for inbound AND outbound traffic explicitly, nothing is automatic
- Rules are processed in numbered order (like a numbered checklist)
- Default behavior: **allow everything**, until you explicitly deny something

**Quick comparison:**

| | Security Group | Network ACL |
|---|---|---|
| Applies to | Individual resource (e.g. one EC2 instance) | Entire subnet |
| Stateful? | Yes (reply traffic auto-allowed) | No (must allow both directions manually) |
| Rule type | Allow rules only | Allow AND deny rules |
| Default | Deny all, then allow specific | Allow all, then deny specific |

**Practical example:** Say you're hosting a website on an EC2 server.
Your Security Group would allow inbound traffic on port 443 (HTTPS)
from anywhere (`0.0.0.0/0`), and port 22 (SSH) only from your own IP
address — so random people on the internet can view your website but
can't try to log into the server itself.

### Load Balancers

A **Load Balancer** sits in front of multiple servers and spreads
incoming traffic across them, so no single server gets overwhelmed —
and if one server fails, traffic automatically routes to the healthy
ones instead.

```
                    Internet
                        │
                        ▼
                Load Balancer
                 /     |     \
                ▼      ▼      ▼
            Server1 Server2 Server3
```

**Why you need one:**
- **High availability** — if Server2 crashes, the load balancer stops sending it traffic and reroutes to Server1/Server3
- **Scalability** — add more servers behind the load balancer as traffic grows, without changing anything users see
- **Single entry point** — users just hit one address (the load balancer's), not each server individually

**AWS's Elastic Load Balancer (ELB) comes in a few types:**

| Type | Works at | Best for |
|---|---|---|
| **Application Load Balancer (ALB)** | Layer 7 (HTTP/HTTPS) | Web applications — can route based on URL path, hostname, etc. |
| **Network Load Balancer (NLB)** | Layer 4 (TCP/UDP) | Extremely high performance, low latency (gaming, real-time apps) |
| **Classic Load Balancer (CLB)** | Legacy, mostly deprecated | Older applications, generally avoid for new projects |

### Auto Scaling

Works hand-in-hand with load balancers: automatically adds more
servers when traffic increases, and removes them when traffic drops
— so you're not paying for idle capacity, and not getting overwhelmed
during a traffic spike.

```
Low traffic  → 2 servers running
Traffic spike → Auto Scaling adds 3 more servers automatically
Traffic drops → Auto Scaling removes the extra servers again
```

---

## Part 4: IAM (Identity and Access Management) Deep Dive

IAM controls **who** can do **what** inside your AWS account.

### Key concepts

- **Root user** — the account owner, full unrestricted access. Should almost never be used day-to-day.
- **IAM Users** — individual identities you create (e.g., one for yourself, one for a teammate), each with their own login and specific permissions
- **IAM Groups** — a way to bundle users together and apply the same permissions to all of them at once (e.g., a "Developers" group)
- **IAM Roles** — a set of permissions that can be *temporarily assumed* — commonly used so one AWS service can securely talk to another (e.g., letting an EC2 server access an S3 bucket) without hardcoding passwords anywhere
- **IAM Policies** — the actual documents (written in JSON) that define exactly what's allowed or denied

**Example policy in plain English:** "Allow this user to read files from
this specific S3 bucket, but not delete them, and not touch any other
bucket."

### The Principle of Least Privilege
A core security concept: only grant the *minimum* permissions someone
actually needs to do their job — nothing more. Don't give a developer
full admin access if they only need to read from one database.

---

## Part 5: Storage Concepts

### S3 (Simple Storage Service)
- Stores **objects** (files) inside **buckets** (like top-level folders, with globally unique names)
- Not a traditional file system — it's "object storage," meaning you store and retrieve whole files by a unique key (like a filename), rather than editing parts of a file in place
- Extremely durable (AWS states 99.999999999% durability — "11 nines") and commonly used for backups, static website hosting, data lakes, storing application assets

### EBS (Elastic Block Store)
- Virtual hard drives attached to a specific EC2 instance
- Unlike S3, this behaves like a normal disk — you can install an OS on it, write to specific parts of files, etc.

**S3 vs EBS, quickly:**

| | S3 | EBS |
|---|---|---|
| Type | Object storage | Block storage (like a hard drive) |
| Attached to | Nothing specific — accessed over the network from anywhere | One specific EC2 instance |
| Use case | Files, backups, static assets, large datasets | Operating system disks, databases needing low-latency disk access |

---

## Part 6: Putting It Together — A Simple Example Architecture

Here's how several of these concepts combine in a realistic (simple)
web application setup:

```
                          Internet
                              │
                     Route 53 (DNS)
                              │
                    Application Load Balancer
                     (in a Public Subnet)
                        /            \
                       ▼              ▼
                 EC2 Server 1    EC2 Server 2
                 (Public Subnet) (Public Subnet)
                 [Security Group: allow 443 from anywhere]
                        \              /
                         ▼            ▼
                      RDS Database
                    (in a Private Subnet)
              [Security Group: allow 3306 only from EC2 servers]
```

- Users hit your domain name (Route 53 resolves it)
- Traffic reaches the Load Balancer, which is the only public entry point
- The Load Balancer spreads traffic across two EC2 servers (for redundancy)
- Each EC2 server can talk to the database, but the database itself
  has no direct internet access — its Security Group only allows
  connections from the EC2 servers' Security Group, nothing else

---

