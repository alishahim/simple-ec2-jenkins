#!/bin/bash
set -e  # Exit on error

echo "Checking if pip is installed..."
if ! command -v pip3 &> /dev/null; then
    echo "pip not found. Installing pip..."
    sudo apt update
    sudo apt install python3-pip -y || sudo yum install python3-pip -y
fi

echo "Installing Python dependencies..."
pip3 install --user -r requirements.txt

echo "Starting the application..."
gunicorn -b 0.0.0.0:5000 app:app
