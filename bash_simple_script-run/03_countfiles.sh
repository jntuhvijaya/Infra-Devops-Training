#!/bin/bash

# 03_count_files.sh
#
# WHAT THIS DOES: looks inside "my_first_folder" (created by
# script 02) and counts how many files are in it.

echo "Looking inside my_first_folder"

ls my_first_folder

echo ""
echo "Now counting how many files that is..."
# The "|" symbol is called a PIPE. It takes the OUTPUT of the command
# on the left and feeds it as INPUT to the command on the right.
# Here: take the file list from "ls", and count how many lines it has.

file_count=$(ls my_first_folder | wc -l)

echo "There are $file_count inside my_first_folder"