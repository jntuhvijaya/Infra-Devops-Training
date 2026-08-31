# Bash Scripting — Concepts + 5 Hands-on Scripts

---

## What is Bash Scripting?

Bash (**B**ourne **A**gain **SH**ell) is the default command-line
interpreter on most Linux systems. A **bash script** is a text file
containing a sequence of bash commands, saved with a `.sh` extension,
that runs top-to-bottom as if you'd typed each line yourself into
the terminal.

## Why use Bash scripting?

- **Automation** — chain together system commands (file management,
  backups, deployments) so they run with one command instead of many
- **It's already there** — every Linux/Mac machine has bash installed,
  no setup needed
- **Perfect for "glue" work** — starting/stopping services, moving
  files, running other programs, checking system status
- **Foundation of DevOps** — CI/CD pipelines, server setup scripts,
  and cron jobs are almost always written in bash

## How to write and run a bash script

```bash
#!/bin/bash        # "shebang" - must be the very first line
echo "hello"        # your commands go here
```

**Run it two ways:**
```bash
bash myscript.sh              # simplest way, works immediately
```
or
```bash
chmod +x myscript.sh          # first, mark it as "executable" (one-time)
./myscript.sh                  # then run it directly
```

---

## Core Bash Concepts (basic → advanced)

### 1. Comments
```bash
# Anything after a # is ignored by bash - it's a note for humans
```

### 2. Variables
```bash
name="Vijaya"          # NO spaces around = (strict rule)
echo "$name"             # use $ to READ a variable's value
echo "${name}"             # curly braces are optional but safer, esp. next to text
```

### 3. User Input
```bash
read user_input          # pauses script, waits for you to type, stores it
echo "You typed: $user_input"
```

### 4. Command-Line Arguments
When you run `bash script.sh apple banana`, inside the script:
```bash
$0     # the script's own name
$1     # first argument -> "apple"
$2     # second argument -> "banana"
$#     # number of arguments passed -> 2
$@     # all arguments as a list
```

### 5. Command Substitution
Capture the OUTPUT of a command into a variable:
```bash
today=$(date)             # modern syntax (preferred)
echo "Today is $today"
```

### 6. Arithmetic
```bash
a=5
b=3
sum=$((a + b))           # math MUST be inside $(( ))
echo "Sum is $sum"
```

### 7. Conditionals (if / elif / else)
```bash
if [ "$a" -gt "$b" ]; then
    echo "a is bigger"
elif [ "$a" -eq "$b" ]; then
    echo "they're equal"
else
    echo "b is bigger"
fi
```

**Common test operators:**
| Operator | Meaning | Used for |
|---|---|---|
| `-eq` | equal to | numbers |
| `-ne` | not equal to | numbers |
| `-gt` | greater than | numbers |
| `-lt` | less than | numbers |
| `-ge` / `-le` | >= / <= | numbers |
| `==` | equal to | strings |
| `!=` | not equal to | strings |
| `-z` | string is empty | strings |
| `-f` | file exists | files |
| `-d` | directory exists | files |
| `-x` | file is executable | files |

### 8. Loops

**For loop:**
```bash
for fruit in apple banana cherry; do
    echo "I like $fruit"
done
```

**While loop:**
```bash
count=1
while [ "$count" -le 5 ]; do
    echo "Count is $count"
    count=$((count + 1))
done
```

**Until loop** (opposite of while — runs until condition becomes true):
```bash
count=1
until [ "$count" -gt 5 ]; do
    echo "Count is $count"
    count=$((count + 1))
done
```

### 9. Case statements
```bash
read fruit
case $fruit in
    apple) echo "It's red or green" ;;
    banana) echo "It's yellow" ;;
    *) echo "I don't know that one" ;;      # * = default/fallback
esac
```

### 10. Functions
```bash
greet() {
    echo "Hello, $1!"    # $1 here is the function's OWN first argument
}
greet "Vijaya"            # -> Hello, Vijaya!
```

### 11. Arrays
```bash
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"            # apple (indexing starts at 0)
echo "${fruits[@]}"              # all elements
echo "${#fruits[@]}"               # number of elements -> 3
```

### 12. Exit codes
```bash
echo "hello"
echo $?              # exit code of the LAST command. 0 = success, non-zero = error
exit 0                # end script early with success
exit 1                # end script early with error
```

### 13. Pipes and redirection
```bash
ls | grep ".txt"           # pipe: feed output of "ls" into "grep"
echo "hello" > file.txt      # > writes to a file (overwrites)
echo "world" >> file.txt      # >> appends to a file
```

### 14. String operations
```bash
str="Hello World"
echo "${#str}"              # length -> 11
echo "${str:0:5}"             # substring from position 0, length 5 -> Hello
echo "${str/World/Bash}"        # replace -> Hello Bash
```

---

## The 5 Hands-on Scripts

Run each with `bash <filename>`. Save each block below as its own
`.sh` file in a `bash_scripts/` folder.

### Script 1 — `01_hello_info.sh`
Concepts used: variables, `echo`, running built-in commands (`date`, `whoami`, `pwd`)

```bash
#!/bin/bash
# ============================================================
# 01_hello_info.sh
# WHAT THIS DOES: prints a greeting, then today's date, your
# username, and your current folder location.
# HOW TO RUN IT: bash 01_hello_info.sh
# ============================================================

echo "Hello! This is my first bash script."

my_name="Vijaya"
echo "My name is $my_name"

echo "Today's date is:"
date

echo "I am logged in as user:"
whoami

echo "I am currently in this folder:"
pwd

echo "Script finished. That's all it does."
```

---

### Script 2 — `02_create_files.sh`
Concepts used: `mkdir`, `touch`, sequential commands

```bash
#!/bin/bash
# ============================================================
# 02_create_files.sh
# WHAT THIS DOES: creates a folder, then creates 3 empty files
# inside it, then shows what got created.
# HOW TO RUN IT: bash 02_create_files.sh
# ============================================================

echo "Creating a folder called 'my_first_folder'..."
mkdir my_first_folder
echo "Folder created."

echo "Now creating 3 empty files inside it..."
touch my_first_folder/notes.txt
touch my_first_folder/todo.txt
touch my_first_folder/ideas.txt
echo "Files created."

echo "Here is what's inside the folder now:"
ls -l my_first_folder

echo "Script finished. You now have a real folder with real files."
```

---

### Script 3 — `03_count_files.sh`
Concepts used: pipes (`|`), command substitution `$(...)`, `wc -l`

```bash
#!/bin/bash
# ============================================================
# 03_count_files.sh
# WHAT THIS DOES: looks inside "my_first_folder" (from script 02)
# and counts how many files are in it.
# HOW TO RUN IT: bash 03_count_files.sh (run script 02 first)
# ============================================================

echo "Looking inside my_first_folder..."
ls my_first_folder

echo ""
echo "Now counting how many files that is..."

# The "|" pipe takes output of the left command and feeds it to the right
file_count=$(ls my_first_folder | wc -l)

echo "There are $file_count file(s) inside my_first_folder"
echo "Script finished."
```

---

### Script 4 — `04_simple_calculator.sh`
Concepts used: `read` (user input), arithmetic `$(( ))`

```bash
#!/bin/bash
# ============================================================
# 04_simple_calculator.sh
# WHAT THIS DOES: asks you to type two numbers, adds them, and
# shows the result.
# HOW TO RUN IT: bash 04_simple_calculator.sh
# ============================================================

echo "Let's add two numbers together."

echo "Enter the first number:"
read first_number

echo "Enter the second number:"
read second_number

result=$((first_number + second_number))

echo "$first_number + $second_number = $result"
echo "Script finished."
```

---

### Script 5 — `05_check_file_exists.sh`
Concepts used: `if`/`else`/`fi`, `-f` file test operator

```bash
#!/bin/bash
# ============================================================
# 05_check_file_exists.sh
# WHAT THIS DOES: asks you for a filename, checks if it exists,
# and tells you yes or no.
# HOW TO RUN IT: bash 05_check_file_exists.sh
# ============================================================

echo "Type a filename to check (example: notes.txt):"
read filename_to_check

if [ -f "$filename_to_check" ]; then
    echo "YES - the file '$filename_to_check' exists."
else
    echo "NO - the file '$filename_to_check' does not exist here."
fi

echo "Script finished."

# TRY THIS: run script 02 first to create my_first_folder/notes.txt,
# then run this script and type: my_first_folder/notes.txt
```

---

## Pushing to GitHub

```bash
git add bash_scripts/
git commit -m "Add bash concepts and 5 hands-on bash scripts"
git push
```
