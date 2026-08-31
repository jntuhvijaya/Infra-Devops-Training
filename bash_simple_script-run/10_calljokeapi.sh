#!/bin/bash

# WHAT THIS DOES: calls a free public API over the internet and
# prints back a random joke. This is your first script that
# talks to something OUTSIDE your own computer.

echo "fetching a random joke from the internet.."

# "curl" is a tool that fetches data from a URL, just like a browser would.
# -s means "silent" (don't show the download progress bar)
# -H adds a "header" - here we're asking the API to send back plain text

curl -s -H "Accept: text/plain" "https://icanhazdadjoke.com/"

echo "script finished"