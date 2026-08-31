#!/bin/bash

# WHAT THIS DOES: asks you for a word/phrase and a folder, then
# searches INSIDE every file in that folder for that word, and
# shows which file and line it was found on.

echo "what word should i search for?"
read word

echo "which folder should i search in?"
read folder

echo "searching..."

# grep looks INSIDE files for matching text
# -r means "recursive" - also search inside sub-folders
# -n means "show the line number" where the match was found
# -i means "case-insensitive" 


grep -rni "$word" "$folder" 2>/dev/null

echo "search finished"