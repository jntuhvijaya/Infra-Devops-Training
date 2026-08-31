#!/usr/bin/env python3

import json

config_file = "sample_data/settings.json"

try:

    with open(config_file, "r") as file:
        settings = json.load(file)

    print("===== CONFIGURATION =====")

    print("Application :", settings.get("application"))
    print("Environment :", settings.get("environment"))
    print("Port :", settings.get("port"))
    print("Debug :", settings.get("debug"))

    if settings.get("environment") == "production":
        print("WARNING: Production configuration detected!")

    if settings.get("port") is None:
        print("WARNING: Port is missing!")

except FileNotFoundError:
    print("Configuration file not found.")

except json.JSONDecodeError:
    print("Configuration file contains invalid JSON.")