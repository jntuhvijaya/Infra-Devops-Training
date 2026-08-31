#!/bin/bash

# WHAT THIS DOES: asks YOU to type in two numbers, then adds
# them together and shows the result. This is your first
# script that takes input WHILE it's running.

echo "Let's add  two numbers..."

echo "Enter the first number:"
read first_number

echo "Enter the second number:"
read second_number

result=$(( first_number + second_number ))

echo "$first_number + $second_number= $result"