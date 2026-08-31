#!/usr/bin/env python3

import os

folder = input("Enter folder to inspect: ")

if not os.path.exists(folder):
    print("Folder does not exist.")
    exit()

file_count = 0
folder_count = 0

print("\n===== DIRECTORY REPORT =====")

for current_path, folders, files in os.walk(folder):

    folder_count += len(folders)
    file_count += len(files)

    print("\nFolder:", current_path)

    for filename in files:
        print("  File:", filename)

print("\n===== SUMMARY =====")
print("Folders found:", folder_count)
print("Files found:", file_count)