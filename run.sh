#!/bin/bash
set -e  # Exit on error

# Navigate to the app directory
cd "$(dirname "$0")"

# Install dependencies (optional, for debugging purposes)
pip install --user -r requirements.txt

# Start Gunicorn
gunicorn -b 0.0.0.0:5000 app:app
