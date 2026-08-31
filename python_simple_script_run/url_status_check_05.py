#!/usr/bin/env python3
# It checks whether a website can be reached.
# for making htto req
import urllib.request

url = input("Enter website URL: ")

try:
# try connecting
    response = urllib.request.urlopen(url, timeout=5)

    print("Website:", url)
    print("Status :", response.status)

    if response.status == 200:
        print("Result : Website is reachable")
    else:
        print("Result : Website responded with another status")

except Exception as error:

    print("Website check failed.")
    print("Reason:", error)