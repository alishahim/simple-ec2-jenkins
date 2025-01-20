#!/bin/bash

# Stop script on error
set -e

echo "Installing Python dependencies..."
python3 -m pip install --no-cache-dir -r requirements.txt

echo "Stopping any running Gunicorn process on port 5000..."
if pgrep -f "gunicorn -b 0.0.0.0:5000" > /dev/null; then
    echo "Gunicorn process found. Stopping it..."
    pkill -f "gunicorn -b 0.0.0.0:5000" || true
else
    echo "No running Gunicorn process found."
fi

echo "Starting Gunicorn server..."
nohup gunicorn -b 0.0.0.0:5000 app:app > gunicorn.log 2>&1 &

echo "Gunicorn server started successfully!"