#!/bin/bash

# Check if user is root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

# Update system and install dependencies
echo "Updating system and installing dependencies..."
apt-get update -y && apt-get install python3 python3-pip -y

if [ $? -ne 0 ]; then
  echo "Failed to install system dependencies. Exiting..."
  exit 1
fi

# Install Python requirements
pip3 install flask
if [ $? -ne 0 ]; then
  echo "Failed to install Flask. Exiting..."
  exit 1
fi

echo "Setup completed successfully!"
