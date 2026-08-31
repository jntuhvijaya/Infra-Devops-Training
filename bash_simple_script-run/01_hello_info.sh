#!/bin/bash

# ============================================================
# 01_hello_info.sh
#
# WHAT THIS DOES: prints a greeting, then shows today's date,
# your username, and where you currently are in the file system.
#
# HOW TO RUN IT:   bash 01_hello_info.sh
# WHAT YOU'LL SEE: a greeting followed by 3 lines of info
# ============================================================

echo "Hello ! This is my first bash script"

name="Vijaya Power"

echo "My name is $name"

# "date" is a real Linux command - it just prints today's date and time
echo "Today's date is:"
date
# "whoami" prints the username you're currently logged in as
echo "I am logging in as user:"
whoami
# "pwd" means "print working directory" - shows where you are right now
echo "I am currently in this folder:"
pwd

echo "The script Finished, That's all it today"

