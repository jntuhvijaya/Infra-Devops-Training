#!/bin/bash

# ============================================================
# 02_backup_folder.sh
# Backs up a folder into a timestamped .tar.gz archive.
# Usage: bash 02_backup_folder.sh /path/to/folder
#
# Concepts used: arguments ($1), if conditions, date command,
# tar (archiving), exit codes
# ============================================================

# $1 = the first argument passed when running the script
target_folder="$1"

# Check if the user actually gave us a folder path
if [ -z "$target_folder" ]; then
    echo "ERROR:please provide a folder to back up."
    echo "Usage: bash 02_backup_folder.sh /path/to/folder"
    exit 1 # something went wrong
fi

# Check if that folder actually exists

if [! -d "$target_folder" ]; then
    echo "Error:'$target_folder' is not a valid directory."
    exit 1
fi

# date +FORMAT lets us build a timestamp string, e.g. 2026-08-25_14-30-00
timestamp=$(date +%y-%m-%d_%H-%M-%S)


# Grab just the folder's own name (strip the path) for a clean archive name
folder_name=$(basename "$target_folder")
backup_name="${folder_name}_backup_${timestamp}.tar.gz"

echo "backing up..."

# tar flags: c=create, z=gzip compress, v=verbose (show files), f=filename
tar -czvf "$backup_name" "$target_folder"

# $? holds the exit code of the LAST command run (tar, in this case)
if [ $? -eq 0 ]; then
    echo "SUCCESS: Backup created -> $backup_name"
else
    echo "ERROR: Backup failed."
    exit 1
fi