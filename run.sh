#!/bin/bash
set -e  # Exit on error

echo "Starting the application..."

# Navigate to the app directory
cd "$(dirname "$0")"

# Install Python dependencies
pip3 install --user -r requirements.txt

# Start Gunicorn
gunicorn -b 0.0.0.0:5000 app:app