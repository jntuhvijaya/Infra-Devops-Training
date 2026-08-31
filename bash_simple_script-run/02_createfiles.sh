#!/bin/bash

# ============================================================
# 02_create_files.sh
#
# WHAT THIS DOES: creates a new folder, then creates 3 empty
# files inside it, then shows you what got created.
#
# HOW TO RUN IT:   bash 02_create_files.sh
# WHAT YOU'LL SEE: confirmation messages, then a file listing
# ============================================================

echo "creating a folder called 'My_first_folder'"
# mkdir means "make directory"
mkdir my_first_folder

echo "Folder has been created..."

echo "Now creating 3 files inside it.."
# touch creates a new, empty file 
touch my_first_folder/file1.txt
touch my_first_folder/file2.txt
touch my_first_folder/file3.txt

echo "Files has been created..."

# ls lists the contents of a folder. -l means "long format" (more detail)
ls -l my_first_folder
