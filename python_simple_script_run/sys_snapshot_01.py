#!/usr/bin/env python3

# this script collects basic info about machine and python

import platform 
# platform- gives info about os and machine
import os
# os-interact with os

print("===== MACHINE SNAPSHOT =====")

# computer's host name
computer_name = platform.node()
operating_system = platform.system()
# gets version info
os_version = platform.release()
python_version = platform.python_version()
# get current working dir
current_folder = os.getcwd()

print("Computer Name :", computer_name)
print("Operating System :", operating_system)
print("OS Version :", os_version)
print("Python Version :", python_version)
print("Current Folder :", current_folder)

print("============================")