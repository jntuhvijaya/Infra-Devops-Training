#!/usr/bin/env python3

# WHAT THIS DOES: asks you for a folder and part of a filename,
# then searches through that folder AND all its sub-folders to
# find matching files.

import os

folder=input("which folder should i search in?")
word=input("which filename")

print("searching..")
count=0

# os.walk() goes through a folder AND every sub-folder inside it,
# one folder at a time. Each time through the loop, it gives us:
#   current_folder = the folder path it's currently looking at
#   subfolders     = list of folder names inside current_folder
#   files          = list of file names inside current_folder


for InfraDevops_Training,python_simple_script_run ,print_name in os.walk(folder):
    for i in print_name:
        if word.lower() in i.lower():
            full_path = os.path.join(python_simple_script_run, i)
            print("Found:", full_path)
            count += 1
 
if count == 0:
    print(f"No files found matching '{word}'")
else:
    print(f"Found {count} matching file(s)")
 
print("Script finished.")


