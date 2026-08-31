#!/bin/bash
# ============================================================
# 01_system_info.sh
# Beginner-friendly script that prints a quick health snapshot
# of the machine: hostname, OS, CPU, memory, disk,
echo "System Information"

hostname_val=$(uname -n)
os_val=$(uname -s)
kernel_val=$(uname -r)
today=$(date)

echo "Hostname: $hostname_val"
echo "OS Type: $os_val"
echo "kernel: $kernel_val"
echo "Today's date: $today"

echo "--------Memory (RAM)-------"
free -h  # -h = human-readable (shows MB/GB instead of raw bytes)
echo ""

echo "-------Disk USAGE---------"
df -h   # -h = human-readable disk space per mounted filesystem
echo ""



