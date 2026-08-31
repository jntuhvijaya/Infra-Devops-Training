#!/usr/bin/env python3

log_file = input("Enter log file path: ")
keyword = input("Enter keyword to count: ")

count = 0

try:
    with open(log_file, "r") as file:

        for line in file:

            if keyword.lower() in line.lower():
                count += 1
                print(line.strip())

    print("\nTotal matches:", count)

except FileNotFoundError:
    print("Log file not found.")