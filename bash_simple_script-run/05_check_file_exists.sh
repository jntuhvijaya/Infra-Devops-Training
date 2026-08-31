#!/bin/bash

# WHAT THIS DOES: asks you to type a filename, then checks
# whether that file actually exists on your system, and tells
# you yes or no. This is your first script with DECISION-MAKING
# (an "if" statement).

echo "Type a filename to check if it exists or not"

read filename

# [ -f "$filename_to_check" ] checks: "does a FILE with this name exist?"
# -f specifically means "is this a regular file" (not a folder)

 if [ -f "$filename" ]; then
     echo "Yes-The file '$filename' exists."
 else
     echo "No-The file '$filename' doesn't exists."

fi
