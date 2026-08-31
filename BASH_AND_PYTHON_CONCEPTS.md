# Bash Scripting & Python Scripting — Complete Concept Guide

---

# PART A: BASH SCRIPTING

## A.1 What is Bash Scripting?

Bash (**B**ourne **A**gain **SH**ell) is the default command-line
interpreter on most Linux systems. A **bash script** is a text file
containing a sequence of bash commands, saved with a `.sh` extension,
that runs top-to-bottom as if you'd typed each line yourself into
the terminal.

## A.2 Why use Bash scripting?

- **Automation** — chain together system commands (file management,
  backups, deployments) so they run with one command instead of many
- **It's already there** — every Linux/Mac machine has bash installed,
  no setup needed
- **Perfect for "glue" work** — starting/stopping services, moving
  files, running other programs, checking system status
- **Foundation of DevOps** — CI/CD pipelines, server setup scripts,
  and cron jobs are almost always written in bash

## A.3 How to write and run a bash script

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

## A.4 Core Bash Concepts (basic → advanced)

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
today=`date`                # old syntax (still works, avoid for new scripts)
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

**For loop** (repeat for each item in a list):
```bash
for fruit in apple banana cherry; do
    echo "I like $fruit"
done
```

**For loop over files:**
```bash
for file in *.txt; do
    echo "Found file: $file"
done
```

**While loop** (repeat WHILE a condition is true):
```bash
count=1
while [ "$count" -le 5 ]; do
    echo "Count is $count"
    count=$((count + 1))
done
```

**Until loop** (repeat UNTIL a condition becomes true — opposite of while):
```bash
count=1
until [ "$count" -gt 5 ]; do
    echo "Count is $count"
    count=$((count + 1))
done
```

### 9. Case statements (cleaner than many elif's)
```bash
read fruit
case $fruit in
    apple) echo "It's a fruit that's red or green" ;;
    banana) echo "It's yellow" ;;
    *) echo "I don't know that one" ;;      # * = default/fallback case
esac
```

### 10. Functions
```bash
greet() {
    echo "Hello, $1!"    # $1 here is the function's OWN first argument
}

greet "Vijaya"            # calling the function -> Hello, Vijaya!
```

### 11. Arrays
```bash
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"            # apple (indexing starts at 0)
echo "${fruits[@]}"              # all elements
echo "${#fruits[@]}"               # number of elements -> 3

for f in "${fruits[@]}"; do
    echo "$f"
done
```

### 12. Exit codes
```bash
echo "hello"
echo $?              # $? = exit code of the LAST command run. 0 = success, non-zero = error

exit 0                # ends the script early with a success code
exit 1                # ends the script early with an error code
```

### 13. Pipes and redirection
```bash
ls | grep ".txt"           # pipe: send output of "ls" into "grep" as input
echo "hello" > file.txt      # > writes output into a file (overwrites)
echo "world" >> file.txt      # >> appends output to a file (doesn't erase)
command < file.txt              # < feeds a file's content INTO a command
```

### 14. String operations
```bash
str="Hello World"
echo "${#str}"              # length of string -> 11
echo "${str:0:5}"             # substring from position 0, length 5 -> Hello
echo "${str/World/Bash}"        # replace World with Bash -> Hello Bash
```

---

# PART B: PYTHON SCRIPTING

## B.1 What is Python Scripting?

Python is a general-purpose programming language. A "python script"
is just a `.py` text file containing python code, run from top to
bottom by the python interpreter.

## B.2 Why use Python?

- **Readable syntax** — closer to plain English than most languages
- **Huge standard library** — file handling, networking, math, regex,
  JSON, all built in without installing anything extra
- **Great for logic-heavy tasks** — data processing, automation with
  conditions/calculations, parsing files, APIs
- Complements bash: bash is best for quick system/file tasks; Python
  is best once your script needs real logic, data structures, or math

## B.3 How to write and run a Python script

```python
#!/usr/bin/env python3
print("hello")
```
Run it:
```bash
python3 myscript.py
```

---

## B.4 Core Python Concepts (basic → advanced)

### 1. Comments
```python
# Anything after a # is ignored - a note for humans
```

### 2. Variables & Data Types
```python
name = "Vijaya"        # string (text)
age = 25                 # integer (whole number)
height = 5.6                # float (decimal number)
is_learning = True             # boolean (True/False)
```

### 3. Input / Output
```python
print("Hello")                    # output to screen
user_input = input("Type: ")        # pause, wait for typed input (always returns a string)
number = int(input("Number: "))       # convert typed text into an integer
```

### 4. Operators
```python
5 + 3      # addition
5 - 3      # subtraction
5 * 3      # multiplication
5 / 3      # division (always gives a float)
5 // 3     # floor division (whole number result, drops remainder)
5 % 3      # modulo (remainder) -> 2
5 ** 2     # exponent (power) -> 25
5 == 3     # equal to -> False
5 != 3     # not equal to -> True
5 > 3      # greater than -> True
```

### 5. Conditionals
```python
age = 20
if age < 13:
    print("child")
elif age < 20:
    print("teenager")
else:
    print("adult")
```

### 6. Loops

**For loop:**
```python
for i in range(5):          # range(5) generates 0,1,2,3,4
    print(i)

fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)
```

**While loop:**
```python
count = 1
while count <= 5:
    print(count)
    count = count + 1
```

**Loop control:**
```python
for i in range(10):
    if i == 5:
        break          # stop the loop entirely
    if i == 2:
        continue         # skip this iteration, go to next
    print(i)
```

### 7. Functions
```python
def greet(name):
    return f"Hello, {name}!"

message = greet("Vijaya")
print(message)          # Hello, Vijaya!
```

### 8. Data Structures

**List** (ordered, changeable collection):
```python
fruits = ["apple", "banana", "cherry"]
fruits.append("mango")      # add an item
print(fruits[0])              # apple (indexing starts at 0)
print(len(fruits))              # 4 (number of items)
```

**Dictionary** (key-value pairs):
```python
person = {"name": "Vijaya", "age": 25}
print(person["name"])         # Vijaya
person["city"] = "Hyderabad"    # add a new key-value pair
```

**Tuple** (ordered, UNchangeable collection):
```python
coordinates = (10, 20)      # once created, can't be modified
```

**Set** (unordered, no duplicates allowed):
```python
unique_numbers = {1, 2, 2, 3}      # becomes {1, 2, 3} automatically
```

### 9. String Methods
```python
text = "Hello World"
text.lower()             # "hello world"
text.upper()               # "HELLO WORLD"
text.split()                 # ["Hello", "World"]
text.replace("World", "Bash")  # "Hello Bash"
text.strip()                    # removes leading/trailing whitespace
len(text)                         # 11 (length)
"World" in text                    # True (membership check)
```

### 10. File Handling
```python
# Writing to a file
with open("notes.txt", "w") as f:
    f.write("Hello file")

# Reading from a file
with open("notes.txt", "r") as f:
    content = f.read()
    print(content)

# "with" automatically closes the file when done - always prefer this pattern
```

### 11. Importing Modules
```python
import os              # gives access to operating-system functions
import sys               # gives access to command-line arguments, etc.
import re                  # regular expressions (pattern matching in text)
from datetime import datetime   # import ONE specific thing from a module

print(os.listdir("."))       # list files in current folder
```

### 12. Command-Line Arguments
```python
import sys
print(sys.argv)          # list of arguments; sys.argv[0] is the script name itself
# Running: python3 script.py hello world
# sys.argv = ['script.py', 'hello', 'world']
```

### 13. Exception Handling (dealing with errors gracefully)
```python
try:
    number = int(input("Enter a number: "))
    result = 10 / number
    print(result)
except ValueError:
    print("That wasn't a valid number")
except ZeroDivisionError:
    print("Can't divide by zero")
```

### 14. List Comprehension (compact way to build lists)
```python
squares = [x * x for x in range(5)]
# equivalent to:
squares = []
for x in range(5):
    squares.append(x * x)
```

---

# PART C: Bash vs Python — When to Use Which

| Task | Better tool |
|---|---|
| Running system commands, moving files | Bash |
| Quick automation of 5-10 command sequences | Bash |
| Complex logic, math, data structures | Python |
| Parsing/processing structured data (JSON, CSV) | Python |
| Talking to APIs | Python |
| Server setup, cron jobs, CI/CD glue scripts | Bash |
| Anything needing real error handling | Python |

Many real DevOps workflows use **both** — a bash script that calls a
python script for the complex part, or vice versa.

---

# PART D: Mapping Concepts to Your Existing Scripts

You already have 5 bash + 5 python scripts in the `beginner/` folder.
Here's which concepts from this guide each one demonstrates:

| Script | Concepts used |
|---|---|
| `bash/01_hello_info.sh` | variables, `echo`, running built-in commands |
| `bash/02_create_files.sh` | `mkdir`, `touch`, sequential commands |
| `bash/03_count_files.sh` | pipes (`\|`), command substitution `$(...)` |
| `bash/04_simple_calculator.sh` | `read` (user input), arithmetic `$(( ))` |
| `bash/05_check_file_exists.sh` | `if`/`else`/`fi`, `-f` file test operator |
| `python/01_hello.py` | variables, data types, `print()` |
| `python/02_simple_calculator.py` | `input()`, type conversion, f-strings |
| `python/03_even_or_odd.py` | `if`/`else`, modulo operator |
| `python/04_list_files.py` | `import os`, `for` loop, lists |
| `python/05_word_counter.py` | `.split()`, `for` loop, `len()` |

**Concepts NOT yet covered by those 10 scripts** (from this guide) that
are worth practicing next: functions, arrays/lists with `.append()`,
while loops, case statements, dictionaries, exception handling
(`try`/`except`), and file reading/writing. Once you're comfortable
with the 10 basics, try modifying one script to add a function or a
while loop — that's the fastest way to actually learn a concept.

---

# PART E: Pushing to GitHub for Vamshi to Review

```bash
# from inside your training repo folder
git add .
git commit -m "Add bash and python scripting concepts + 10 hands-on scripts"
git push
```

**For the hands-on screenshots he mentioned:** when you run each
script, take a screenshot showing BOTH the command you typed AND the
output it produced — that's the proof of "I ran this and understood
the result," not just "I wrote this code." You can drop screenshots
into a folder like `beginner/screenshots/` and reference them in your
README, or just have them ready to share live.
