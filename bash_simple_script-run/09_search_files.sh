#!/bin/bash

# WHAT THIS DOES: asks you for a folder and a filename (or part
# of one) to search for, then finds every matching file inside
# that folder.


echo "which folder should I search in?"
read folder_search

echo "what filename you are looking for "
read file_search

echo "searching..."

# "find" looks through a folder (and all its sub-folders) for files.
# -iname means "match this name, case-insensitive"
# "*$search_term*" means "anything before AND after what you typed"
# 2>/dev/null hides permission-denied error messages, keeps output clean

find "$folder_search" -iname "*file_search*" 2>/dev/null

echo "search finished"