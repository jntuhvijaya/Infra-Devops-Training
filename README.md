# DevOps Training Notes — Vijaya

Personal learning log for Infra/DevOps training assigned by Vamshi Karre.
Covers: Agile, Microservices vs Monolithic, and Linux Administration.
Each section has theory + hands-on commands I've actually run.

---

## 1. What is Agile Process?

### The basic idea
Agile is a way of building software in **small, working pieces** delivered
repeatedly, instead of trying to plan and build the *entire* product
up front and hand it over at the end (that older style is called
**Waterfall**).

Think of it like this:
- **Waterfall**: plan everything → build everything → test everything → release. One big delivery at the end. If requirements change halfway, it's painful and expensive.
- **Agile**: plan a small chunk → build it → test it → release/demo it → get feedback → repeat. Requirements can change between chunks because you're not locked into a giant upfront plan.

### Core values (Agile Manifesto, simplified)
1. Individuals and interactions over processes and tools
2. Working software over comprehensive documentation
3. Customer collaboration over contract negotiation
4. Responding to change over following a rigid plan

### Key vocabulary you'll hear in standups/tickets
| Term | Meaning |
|---|---|
| **Sprint** | A fixed time box (usually 1–2 weeks) where a set of work is completed |
| **Backlog** | The full list of features/tasks/bugs waiting to be worked on |
| **User Story** | A requirement written from the user's point of view: "As a [user], I want [thing], so that [reason]" |
| **Standup / Daily Scrum** | A short daily meeting: what I did yesterday, what I'll do today, any blockers |
| **Sprint Planning** | Meeting at the start of a sprint to decide what goes into it |
| **Sprint Review / Demo** | Showing the finished work to stakeholders at the end of a sprint |
| **Retrospective** | Team discusses what went well / what didn't, to improve the next sprint |
| **Product Owner** | Person who decides *what* gets built and prioritizes the backlog |
| **Scrum Master** | Person who removes blockers and keeps the process running smoothly |
| **Velocity** | How much work a team typically completes per sprint (used for planning) |

### Scrum vs Kanban (the two most common Agile flavors)
- **Scrum**: work happens in fixed sprints, with defined roles (Product Owner, Scrum Master, Dev Team) and ceremonies (planning, standup, review, retro).
- **Kanban**: continuous flow, no fixed sprints. Work items move across a board: `To Do → In Progress → Review → Done`. Focus is on limiting how much work is "in progress" at once.

### Hands-on (no tools needed, just practice thinking in Agile terms)
- [ ] Write 3 user stories for a feature you're currently building on the HR AI Toolkit, in the format: *"As a [role], I want [feature], so that [benefit]"*
- [ ] Look at your team's task board (Jira/Trello/GitLab boards) and identify: current sprint, backlog, in-progress items
- [ ] Note down what a standup update from you would sound like today (yesterday/today/blockers)

### Where it connects to what you already do
Your recent MR for "Step 13 (Orientation and Induction)" and phased onboarding work is a great real example — each "Step" of onboarding automation is essentially a **user story** being delivered incrementally, sprint by sprint, rather than one giant onboarding-system release.

---

## 2. Microservices vs Monolithic Architecture

### Monolithic — the basic idea
One single, large application. All the code — UI, business logic,
database access — lives together and is deployed as **one unit**.

```
┌─────────────────────────────┐
│        Monolith App         │
│  UI + Business Logic + DB   │
│      (all one codebase,     │
│       one deployment)       │
└─────────────────────────────┘
```

**Pros:**
- Simple to develop early on — one codebase, one repo
- Easy to test end-to-end (everything is in one process)
- Simple deployment (just one thing to deploy)

**Cons:**
- As it grows, the codebase becomes hard to understand/maintain
- One small change requires re-deploying the *entire* app
- Scaling means scaling the *whole* app, even if only one part is under load
- One bug can crash the entire application
- Hard for large teams to work independently without stepping on each other

### Microservices — the basic idea
The application is broken into **many small, independent services**,
each responsible for one specific capability, communicating over
the network (usually via REST APIs or message queues).

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Auth    │   │  Orders  │   │ Payments │   │ Notify   │
│ Service  │   │ Service  │   │ Service  │   │ Service  │
│  + own   │   │  + own   │   │  + own   │   │  + own   │
│    DB    │   │    DB    │   │    DB    │   │    DB    │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
      ▲              ▲              ▲              ▲
      └──────────────┴──── API Gateway ─────────────┘
```

**Pros:**
- Each service can be built, deployed, and scaled independently
- Different services can even use different tech stacks/languages
- A bug in one service doesn't necessarily crash the others
- Teams can own individual services and move independently

**Cons:**
- Much more operational complexity — you're now managing many deployments, not one
- Network calls between services add latency and failure points
- Harder to test end-to-end (distributed system debugging)
- Needs infrastructure investment: service discovery, API gateways, monitoring, containers (this is where Docker/Podman, Kubernetes, CI/CD come in)
- Data consistency across services is harder (no single shared database)

### Quick comparison table
| Aspect | Monolithic | Microservices |
|---|---|---|
| Deployment | One unit | Many independent units |
| Scaling | Scale the whole app | Scale individual services |
| Codebase | Single, shared | Multiple, separate |
| Tech stack | Usually one stack | Can mix stacks per service |
| Failure impact | Can bring down everything | Usually isolated to one service |
| Complexity (early stage) | Lower | Higher |
| Complexity (at scale) | Higher (becomes unwieldy) | Lower (manageable per-service) |
| Team structure | Works fine for small teams | Suited to multiple independent teams |
| Good for | Startups, small apps, MVPs | Large, complex, evolving systems |

### Where this connects to your work
The **AAF (Agentic Assembly Framework)** setup you work with, where the HR AI Toolkit has separate backend endpoints, tool wrappers, a gateway (`localhost:9002/execute`), and a frontend — is architected in a microservices-influenced style: distinct pieces talking over an API gateway rather than one monolith doing everything.

### Hands-on
- [ ] Diagram (on paper or draw.io) how the HR AI Toolkit's pieces (gateway, backend endpoints, frontend, state/DB) map onto the monolith vs microservices picture above
- [ ] Note one real trade-off you've personally hit in this project that matches a pro/con from the table above

---

## 3. Linux Administration — Full Curriculum

Practice every command below yourself in a real Linux environment
(WSL, VM, or cloud instance) via PuTTY/SSH. Reading isn't enough —
type them, break things, fix them.

### 3.1 Permissions

Every file has an **owner**, a **group**, and **permission bits** for
owner / group / others: `read (r)`, `write (w)`, `execute (x)`.

```bash
ls -l file.txt              # shows: -rwxr-xr-- 1 user group ...
```
Reading `-rwxr-xr--`:
- `-` = file type (`-` file, `d` directory, `l` symlink)
- `rwx` = owner permissions (read, write, execute)
- `r-x` = group permissions
- `r--` = others permissions

**Changing permissions:**
```bash
chmod 755 script.sh          # numeric: owner=7(rwx) group=5(r-x) other=5(r-x)
chmod u+x script.sh           # symbolic: add execute for user(owner)
chmod g-w file.txt            # remove write for group
chmod o=r file.txt            # set others to read-only
chmod -R 755 folder/          # recursive, applies to all contents
```
Numeric values: `r=4, w=2, x=1` → add them up per role (owner/group/other).

**Changing ownership:**
```bash
chown newuser file.txt              # change owner
chown newuser:newgroup file.txt      # change owner and group
chown -R user:group folder/           # recursive
```

**Hands-on:**
- [ ] Create a script, make it non-executable, try to run it (should fail), then `chmod +x` and run it
- [ ] Create a file, change its owner and group, verify with `ls -l`

---

### 3.2 Files and Directories

```bash
pwd                          # print working directory
ls -la                        # list all files (including hidden), long format
cd path/                      # change directory
cd ..                         # go up one level
cd ~                          # go to home directory
mkdir dirname                  # make directory
mkdir -p a/b/c                  # make nested directories in one go
touch file.txt                  # create empty file / update timestamp
cp file.txt copy.txt              # copy file
cp -r dir1/ dir2/                  # copy directory recursively
mv old.txt new.txt                  # rename/move
rm file.txt                        # delete file
rm -r dirname/                      # delete directory recursively
rm -rf dirname/                      # force delete, no confirmation (be careful!)
cat file.txt                         # print entire file
less file.txt                         # scrollable file viewer (q to quit)
head -n 10 file.txt                     # first 10 lines
tail -n 10 file.txt                      # last 10 lines
ln -s target linkname                     # create a symbolic link
```

**Hands-on:**
- [ ] Create a nested directory structure with `mkdir -p`, populate it with files, then remove it with `rm -r`

---

### 3.3 Searching

```bash
find / -name "*.log"                    # find files by name pattern
find . -type f -mtime -1                 # files modified in the last day
find . -type d                            # find only directories
find . -size +100M                         # files larger than 100MB

grep "error" logfile.txt                    # search for a string in a file
grep -r "TODO" ./project/                    # recursive search across a folder
grep -i "warning" logfile.txt                 # case-insensitive
grep -n "error" logfile.txt                    # show line numbers
grep -c "error" logfile.txt                     # count matches

locate filename                                  # fast search using a pre-built index
which python3                                      # find path of an executable
whereis git                                          # find binary/source/man locations
```

**Hands-on:**
- [ ] Search your project folder for all `.py` files modified today
- [ ] `grep` for a specific function name across your project directory

---

### 3.4 Text Processing

```bash
cat file.txt                        # dump contents
wc -l file.txt                       # count lines
wc -w file.txt                        # count words

sort file.txt                          # sort lines alphabetically
sort -n numbers.txt                     # numeric sort
sort -r file.txt                         # reverse sort
uniq file.txt                             # remove adjacent duplicate lines (use after sort)

cut -d',' -f1 data.csv                     # extract 1st column from CSV
awk '{print $1}' file.txt                   # print first column (whitespace-separated)
sed 's/old/new/g' file.txt                   # find & replace text
sed -i 's/old/new/g' file.txt                 # find & replace, edit file in-place

tr 'a-z' 'A-Z' < file.txt                       # translate/transform characters
diff file1.txt file2.txt                         # compare two files
```

**Hands-on:**
- [ ] Take a log file, use `grep` to filter error lines, then `wc -l` to count them
- [ ] Use `sed` to replace a word across a test file

---

### 3.5 Processes

```bash
ps aux                        # list all running processes
ps aux | grep python            # filter processes by name
top                              # live process monitor (press q to exit)
htop                              # nicer interactive version (may need install)

kill <PID>                          # gracefully stop a process
kill -9 <PID>                        # force kill
killall processname                   # kill by process name

jobs                                    # list background jobs in current shell
bg                                       # resume a job in background
fg                                        # bring a job to foreground
command &                                  # run a command in background
nohup command &                             # run command immune to hangups (survives terminal close)

systemctl status servicename                  # check status of a systemd service
```

**Hands-on:**
- [ ] Start a long-running command (e.g. `sleep 300 &`), find its PID with `ps aux`, then kill it
- [ ] Practice `top`/`htop` to identify which process is using the most CPU/memory

---

### 3.6 Package Management

**Debian/Ubuntu (apt):**
```bash
sudo apt update                         # refresh package index
sudo apt upgrade                          # upgrade installed packages
sudo apt install packagename                # install a package
sudo apt remove packagename                  # uninstall (keep config files)
sudo apt purge packagename                    # uninstall + remove config
apt list --installed                            # list installed packages
apt search keyword                                # search for a package
```

**RHEL/CentOS/Fedora (yum/dnf):**
```bash
sudo yum install packagename
sudo dnf install packagename           # newer systems use dnf
sudo yum remove packagename
```

**Python (pip):**
```bash
pip install packagename
pip list
pip uninstall packagename
```

**Hands-on:**
- [ ] Install a small utility (e.g. `tree` or `htop`) via `apt`
- [ ] Check installed version with `apt list --installed | grep <name>`

---

### 3.7 Services

Most modern Linux systems use **systemd** to manage services (background
processes like web servers, databases, docker daemons).

```bash
systemctl status servicename          # check if running
sudo systemctl start servicename        # start a service
sudo systemctl stop servicename          # stop a service
sudo systemctl restart servicename        # restart
sudo systemctl enable servicename          # start automatically on boot
sudo systemctl disable servicename          # don't start on boot
journalctl -u servicename                    # view service logs
journalctl -u servicename -f                  # follow logs live
```

**Hands-on:**
- [ ] Check the status of `ssh` or `docker`/`podman` service on your machine
- [ ] Stop and restart a service, confirm with `systemctl status`

---

### 3.8 Archives (Compression)

```bash
tar -cvf archive.tar folder/            # create a tar archive
tar -xvf archive.tar                      # extract a tar archive
tar -czvf archive.tar.gz folder/            # create + gzip compress
tar -xzvf archive.tar.gz                      # extract gzip tar
tar -tvf archive.tar                            # list contents without extracting

zip -r archive.zip folder/                        # create zip
unzip archive.zip                                    # extract zip

gzip file.txt                                          # compress a single file (-> file.txt.gz)
gunzip file.txt.gz                                       # decompress
```

**Hands-on:**
- [ ] Archive a project folder into `.tar.gz`, then extract it into a new location to confirm it worked

---

### 3.9 Networking

```bash
ping google.com                    # test connectivity
curl -I https://example.com          # fetch headers only
curl https://example.com               # fetch full response
wget https://example.com/file.zip        # download a file

ip a                                       # show network interfaces & IPs
ifconfig                                     # older equivalent (may need net-tools)
netstat -tulnp                                 # show open ports & listening services
ss -tulnp                                        # modern replacement for netstat

ssh user@host                                       # remote login
ssh -i keyfile.pem user@host                          # login using a specific key
scp file.txt user@host:/remote/path/                    # copy file to remote over SSH
scp user@host:/remote/file.txt .                          # copy file from remote

hostname                                                    # show this machine's hostname
hostname -I                                                   # show IP address(es)
```

**Hands-on:**
- [ ] `ping` and `curl -I` a public site to confirm connectivity
- [ ] `ssh` into the training Linux VM using PuTTY/terminal, and `scp` a test file to/from it

---

### 3.10 System Information

```bash
uname -a                     # kernel & system info
hostnamectl                    # detailed host info (OS, kernel, arch)
df -h                            # disk space usage, human-readable
du -sh folder/                     # size of a specific folder
free -h                              # memory (RAM) usage
uptime                                  # how long system has been running + load average
lscpu                                     # CPU details
lsblk                                       # list block devices/disks
cat /etc/os-release                           # which Linux distro/version
whoami                                          # current logged-in user
id                                                # current user's UID/GID and groups
```

**Hands-on:**
- [ ] Check disk usage (`df -h`) and memory usage (`free -h`) on your training VM
- [ ] Identify your distro (`cat /etc/os-release`) and CPU info (`lscpu`)

---

## 4. Pushing This to GitHub

Once you've worked through the checkboxes above, push your notes + any
scripts/screenshots as evidence of hands-on practice.

```bash
# one-time setup in your project folder
git init
git add README.md
git commit -m "Add DevOps training notes: Agile, Microservices, Linux"

# connect to your GitHub repo (create the repo on github.com first)
git remote add origin https://github.com/<your-username>/<repo-name>.git
git branch -M main
git push -u origin main

# for future updates as you complete more hands-on tasks
git add .
git commit -m "Add hands-on notes for Linux networking section"
git push
```

**Tip:** as you complete each hands-on checkbox above, tick it off `[x]`
and commit — this gives you a clean commit history showing incremental
progress, which is a good habit to demo to your team lead directly.
