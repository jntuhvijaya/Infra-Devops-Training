# Networking, OS Basics & Text Processing (awk/sed/cut) — Full Guide

---

## PART 1: Linux Networking Basics

### What actually happens when you visit a website?
1. You type `google.com` in a browser.
2. Your computer asks a **DNS server**: "what IP address is google.com?"
3. DNS replies with something like `142.250.183.14`.
4. Your computer sends a request to that IP over the network.
5. The server at that IP sends back the webpage.

Every step above maps to a real Linux networking concept below.

---

### 1.1 IP Addresses — the basics

An **IP address** is a unique numeric label identifying a device on a network.
The most common form is **IPv4**: four numbers (0-255) separated by dots.

```
192.168.1.10
```

Each of those 4 numbers is called an **octet** (8 bits = 1 byte), so a full
IPv4 address is 32 bits total.

**Public vs Private IPs:**
- **Public IP** — reachable from the internet, unique worldwide (e.g. your router's IP as seen by the outside world)
- **Private IP** — only valid inside a local network (home/office), reused by millions of networks worldwide. Reserved ranges:

| Range | Example |
|---|---|
| `10.0.0.0 – 10.255.255.255` | `10.0.0.5` |
| `172.16.0.0 – 172.31.255.255` | `172.16.5.4` |
| `192.168.0.0 – 192.168.255.255` | `192.168.1.10` |

 `python3 05_ip_subnet_checker.py 192.168.1.10` (from the scripts folder) tells you instantly if an IP is private/public/loopback.

**Special addresses:**
- `127.0.0.1` — **loopback**, always means "this same machine" (aka `localhost`)
- `255.255.255.255` — broadcast address

---

### 1.2 Subnetting — the part everyone finds confusing at first

A **subnet mask** splits an IP address into two parts:
- **Network portion** — identifies which network you're on
- **Host portion** — identifies which specific device on that network

**CIDR notation** is the modern shorthand: `192.168.1.0/24`
The `/24` means: the first 24 bits are the network part, the remaining
8 bits are for host addresses.

```
192.168.1.0/24
└─────┬─────┘ └┬┘
   Network    24 bits reserved for network
              (leaves 8 bits = 256 addresses for hosts)
```

**Why subnetting matters:** it lets you divide one big network into
smaller, isolated segments (e.g. separate the "servers" network from the
"office wifi" network) for security and organization.

**Common prefix lengths and what they mean:**

| CIDR | Subnet Mask | Total Addresses | Usable Hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /28 | 255.255.255.240 | 16 | 14 |
| /30 | 255.255.255.252 | 4 | 2 |

*(Usable hosts = total minus 2, because the first address is reserved for
the network itself and the last is the broadcast address.)*

```bash
python3 05_ip_subnet_checker.py 192.168.1.0/24
python3 05_ip_subnet_checker.py 192.168.1.0/28
```
Run both and compare — watch how the usable host count shrinks as the
prefix number goes up. That's the core intuition: **bigger /number = smaller network.**

---

### 1.3 DNS (Domain Name System)

DNS is the internet's phonebook — it translates human-friendly names
(`google.com`) into IP addresses (`142.250.183.14`) that computers
actually use to route traffic.

**Common DNS record types:**

| Record | Purpose |
|---|---|
| `A` | Maps a domain name to an IPv4 address |
| `AAAA` | Maps a domain name to an IPv6 address |
| `CNAME` | Alias — points one domain name to another domain name |
| `MX` | Mail server for the domain (used for email routing) |
| `TXT` | Arbitrary text, often used for verification/security records |
| `NS` | Which DNS servers are authoritative for this domain |

**Commands:**
```bash
nslookup google.com          # basic DNS lookup
dig google.com                 # more detailed DNS lookup (if installed)
getent hosts google.com          # uses the system's own resolver
cat /etc/resolv.conf               # shows which DNS servers your machine uses
```

**commands** run `bash 05_network_check.sh google.com` from the bash
scripts folder — it does a DNS lookup, ping, and HTTP check all in one go.

---

### 1.4 Ports and Protocols

A **port** is a numbered "door" on a machine that a specific service listens on.
An IP address gets you to the right machine; a port gets you to the right
*service* on that machine.

| Port | Protocol/Service |
|---|---|
| 22 | SSH (remote login — this is what PuTTY uses) |
| 80 | HTTP (unencrypted web traffic) |
| 443 | HTTPS (encrypted web traffic) |
| 53 | DNS |
| 3306 | MySQL database |
| 5432 | PostgreSQL database |

**Check what's listening on your machine:**
```bash
ss -tulnp          # modern tool: shows listening TCP/UDP ports + which process
netstat -tulnp       # older equivalent
```

---

### 1.5 TCP vs UDP (quick primer)
- **TCP** — reliable, ordered, connection-based. Used when you need every packet to arrive correctly (web pages, file downloads, SSH).
- **UDP** — fast, no guarantee of delivery or order. Used when speed matters more than perfection (video streaming, DNS lookups, online gaming).

---

## PART 2: Operating System Basics

### What is an OS, really?
The Operating System sits between your hardware (CPU, RAM, disk) and
the applications you run. It manages:
- **Processes** — running programs
- **Memory** — allocating RAM to each process
- **File system** — organizing data on disk
- **Devices** — talking to hardware (network cards, disks, etc.)

### Kernel vs Shell
- **Kernel** — the core of the OS, talks directly to hardware, manages processes/memory. You never interact with it directly.
- **Shell** — the program that takes your typed commands (`ls`, `cd`, `grep`...) and asks the kernel to execute them. Bash is the most common Linux shell.

```
You type a command
        ↓
     Shell (bash) interprets it
        ↓
     Kernel executes it against hardware
        ↓
     Result shown back in terminal
```

### Processes, quickly revisited
Every running program is a **process** with a unique **PID** (Process ID).
```bash
ps aux              # list all processes
top                   # live view, sorted by resource usage
```
Run `python3 02_system_health.py` from the scripts folder to see a live
snapshot of your OS, CPU, memory, and disk — it's built entirely from
concepts in this section.

---

## PART 3: awk, sed, cut — Text Processing Trio

These three tools are the bread and butter of Linux text processing —
they let you slice, filter, and transform text without opening an editor.

### 3.1 `cut` — extract specific columns

`cut` is the simplest of the three — good for well-structured,
delimiter-separated data (like CSVs).

```bash
# Given a file "data.csv" with content like: name,age,city
cut -d',' -f1 data.csv          # -d = delimiter, -f = field number -> prints "name" column
cut -d',' -f1,3 data.csv          # multiple fields -> "name" and "city"
cut -d',' -f2-3 data.csv            # a range of fields -> "age" and "city"
cut -c1-5 file.txt                    # extract characters 1 to 5 of each line
```


```bash
echo "vijaya,25,hyderabad" | cut -d',' -f1
# Output: vijaya
```

---

### 3.2 `sed` — stream editor (find & replace, and more)

`sed` processes text line-by-line and can substitute, delete, or
transform content — without opening a file in an editor.

```bash
sed 's/old/new/' file.txt              # replace FIRST occurrence per line
sed 's/old/new/g' file.txt               # replace ALL occurrences per line (g = global)
sed -i 's/old/new/g' file.txt              # -i = edit the file IN PLACE (careful, this overwrites!)
sed -n '5p' file.txt                          # print only line 5
sed -n '2,4p' file.txt                          # print lines 2 through 4
sed '3d' file.txt                                 # delete line 3
sed '/pattern/d' file.txt                           # delete any line matching "pattern"
```


```bash
echo "hello world" | sed 's/world/linux/'
# Output: hello linux
```

---

### 3.3 `awk` — the powerful one (column-based processing + logic)

`awk` treats each line as a set of fields (columns) and lets you write
small programs to process them — closer to a mini scripting language
than a simple filter.

```bash
awk '{print $1}' file.txt              # print the first column (default delimiter = whitespace)
awk '{print $1, $3}' file.txt            # print columns 1 and 3
awk -F',' '{print $2}' data.csv            # -F sets a custom delimiter (comma here)
awk '{print NR, $0}' file.txt                # NR = current line number, $0 = whole line
awk '{print NF}' file.txt                      # NF = number of fields on that line
awk '$3 > 100 {print $0}' data.txt               # print lines WHERE column 3 is greater than 100
awk '{sum += $2} END {print sum}' data.txt         # sum up column 2 across all lines
```


```bash
echo "vijaya 25 hyderabad" | awk '{print $1, $3}'
# Output: vijaya hyderabad
```

---

### 3.4 When to use which

| Tool | Best for |
|---|---|
| `cut` | Simple column extraction from clean, delimiter-separated data |
| `sed` | Find/replace, deleting lines, simple line-based edits |
| `awk` | Anything involving columns + conditions/math/logic |
| `grep` | Just finding/filtering lines that match a pattern (no editing) |

### 3.5 A real combined example (this is where it clicks)
Say you have a log file and want the IP addresses of all lines
containing "ERROR", sorted by frequency:

```bash
grep "ERROR" access.log | awk '{print $1}' | sort | uniq -c | sort -rn
```
Reading it left to right:
1. `grep "ERROR"` — keep only ERROR lines
2. `awk '{print $1}'` — keep only the first column (assume it's the IP)
3. `sort` — sort alphabetically (needed before `uniq`)
4. `uniq -c` — count consecutive duplicates
5. `sort -rn` — sort numerically, descending, so the most frequent IP is on top

This "pipe chain" style — small tools combined with `|` — is the core
Linux philosophy: each tool does ONE thing well, and you combine them.

---

