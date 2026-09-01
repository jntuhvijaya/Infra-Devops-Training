# Python Scripting — Concepts + 5 Hands-on Scripts

---

## What is Python Scripting?

Python is a general-purpose programming language. A "python script"
is a `.py` text file containing python code, run from top to bottom
by the python interpreter.

## Why use Python?

- **Readable syntax** — closer to plain English than most languages
- **Huge standard library** — file handling, networking, math, regex,
  JSON, all built in without installing anything extra
- **Great for logic-heavy tasks** — data processing, automation with
  conditions/calculations, parsing files, APIs
- Complements bash: bash is best for quick system/file tasks; Python
  is best once your script needs real logic, data structures, or math

## How to write and run a Python script

```python
#!/usr/bin/env python3
print("hello")
```
Run it:
```bash
python3 myscript.py
```

---

## Core Python Concepts (basic → advanced)

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
user_input = input("Type: ")        # pause, wait for typed input (always a string)
number = int(input("Number: "))       # convert typed text into an integer
```

### 4. Operators
```python
5 + 3      # addition
5 - 3      # subtraction
5 * 3      # multiplication
5 / 3      # division (always gives a float)
5 // 3     # floor division (whole number result)
5 % 3      # modulo (remainder) -> 2
5 ** 2     # exponent (power) -> 25
5 == 3     # equal to -> False
5 != 3     # not equal to -> True
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

**List** (ordered, changeable):
```python
fruits = ["apple", "banana", "cherry"]
fruits.append("mango")
print(fruits[0])              # apple
print(len(fruits))              # 4
```

**Dictionary** (key-value pairs):
```python
person = {"name": "Vijaya", "age": 25}
print(person["name"])         # Vijaya
person["city"] = "Hyderabad"
```

**Tuple** (ordered, unchangeable):
```python
coordinates = (10, 20)
```

**Set** (unordered, no duplicates):
```python
unique_numbers = {1, 2, 2, 3}      # becomes {1, 2, 3}
```

### 9. String Methods
```python
text = "Hello World"
text.lower()             # "hello world"
text.upper()               # "HELLO WORLD"
text.split()                 # ["Hello", "World"]
text.replace("World", "Bash")  # "Hello Bash"
len(text)                         # 11
"World" in text                    # True
```

### 10. File Handling
```python
with open("notes.txt", "w") as f:
    f.write("Hello file")

with open("notes.txt", "r") as f:
    content = f.read()
    print(content)
# "with" automatically closes the file when done - always prefer this
```

### 11. Importing Modules
```python
import os              # operating-system functions
import sys               # command-line arguments, etc.
print(os.listdir("."))       # list files in current folder
```

### 12. Exception Handling
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

---

## The 5 Hands-on Scripts

Run each with `python3 <filename>`. Save each block below as its own
`.py` file in a `python_scripts/` folder.

### Script 1 — `01_hello.py`
Concepts used: variables, data types, `print()`

```python
#!/usr/bin/env python3
# ============================================================
# 01_hello.py
# WHAT THIS DOES: prints a greeting and shows how variables work.
# HOW TO RUN IT: python3 01_hello.py
# ============================================================

print("Hello! This is my first python script.")

my_name = "Vijaya"
print("My name is", my_name)

my_age = 25
print("My age is", my_age)

next_year_age = my_age + 1
print("Next year I will be", next_year_age)

print("Script finished. That's all it does.")
```

---

### Script 2 — `02_simple_calculator.py`
Concepts used: `input()`, type conversion, f-strings

```python
#!/usr/bin/env python3
# ============================================================
# 02_simple_calculator.py
# WHAT THIS DOES: asks for two numbers, then adds, subtracts,
# multiplies, and divides them.
# HOW TO RUN IT: python3 02_simple_calculator.py
# ============================================================

first_number = int(input("Enter the first number: "))
second_number = int(input("Enter the second number: "))

total = first_number + second_number
difference = first_number - second_number
product = first_number * second_number
quotient = first_number / second_number

print(f"{first_number} + {second_number} = {total}")
print(f"{first_number} - {second_number} = {difference}")
print(f"{first_number} * {second_number} = {product}")
print(f"{first_number} / {second_number} = {quotient}")

print("Script finished.")
```

---

### Script 3 — `03_even_or_odd.py`
Concepts used: `if`/`else`, modulo operator

```python
#!/usr/bin/env python3
# ============================================================
# 03_even_or_odd.py
# WHAT THIS DOES: asks for a number and tells you if it's even
# or odd.
# HOW TO RUN IT: python3 03_even_or_odd.py
# ============================================================

number = int(input("Enter a whole number: "))

remainder = number % 2

if remainder == 0:
    print(f"{number} is EVEN")
else:
    print(f"{number} is ODD")

print("Script finished.")
```

---

### Script 4 — `04_list_files.py`
Concepts used: `import os`, `for` loop, lists

```python
#!/usr/bin/env python3
# ============================================================
# 04_list_files.py
# WHAT THIS DOES: shows every file and folder in the current
# directory, one by one.
# HOW TO RUN IT: python3 04_list_files.py
# ============================================================

import os

items = os.listdir(".")

print("Here is everything in this folder:")

count = 0
for item in items:
    count = count + 1
    print(count, "-", item)

print(f"Total items found: {count}")
print("Script finished.")
```

---

### Script 5 — `05_word_counter.py`
Concepts used: `.split()`, `for` loop, `len()`

```python
#!/usr/bin/env python3
# ============================================================
# 05_word_counter.py
# WHAT THIS DOES: asks for a sentence, counts the words, and
# shows each word one by one.
# HOW TO RUN IT: python3 05_word_counter.py
# ============================================================

sentence = input("Type a sentence: ")

words = sentence.split()
word_count = len(words)

print(f"Your sentence has {word_count} word(s)")
print("Here they are, one by one:")

position = 0
for word in words:
    position = position + 1
    print(position, "-", word)

print("Script finished.")
```

---

