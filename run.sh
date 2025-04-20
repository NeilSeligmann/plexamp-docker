#!/bin/bash

set -e

echo "Running as user: $(whoami)"

echo "--------------------------------"
echo "Pulseaudio version: $(pulseaudio --version)"
# echo "Pulseaudio help:"
# pulseaudio --help
echo "--------------------------------"

# Kill any existing pulseaudio processes
echo "Stopping any existing Pulseaudio processes..."
pulseaudio --kill 2>/dev/null || true

# Clean up existing pulseaudio config files
echo "Cleaning up Pulseaudio configuration..."
rm -rf ~/.config/pulse/* /var/run/pulse/* 2>/dev/null || true

# Check if pulseaudio is already running
if pulseaudio --check; then
    echo "Pulseaudio is still running after cleanup attempt!"
    echo "Trying to force kill..."
    pkill -9 pulseaudio || true
else
    echo "No Pulseaudio running, starting fresh..."
fi

echo "Starting Pulseaudio..."
# Start pulseaudio and capture the output
if ! pulseaudio -D --verbose -v --exit-idle-time=-1 --system --disallow-exit --log-level=4 --log-target=stderr --disable-shm; then
    echo "Failed to start Pulseaudio. Logs:"
    # Print the logs if available
    if [ -f ~/.config/pulse/log ]; then
        cat ~/.config/pulse/log
    elif [ -f /var/log/pulse/log ]; then
        cat /var/log/pulse/log
    else
        echo "No pulseaudio logs found."
    fi
    exit 1
fi
echo "Pulseaudio started!"

# systemctl status --user pipewire-pulse.service

# pacmd load-module module-virtual-sink sink_name=v1

# pactl -help
# pactl list short sinks

echo "Protected fifos status: $(cat /proc/sys/fs/protected_fifos)"

# Use environment variables with defaults
PIPE_FILE=${PIPE_FILE:-/tmp/audio/plexamp.out}
SINK_NAME=${SINK_NAME:-Plexamp}
FORMAT=${FORMAT:-s16le}
RATE=${RATE:-48000}

echo "Creating Pulseaudio FIFO at ${PIPE_FILE}"
# Create the directory if it doesn't exist
mkdir -p $(dirname ${PIPE_FILE})

# Create the FIFO only if it doesn't exist
if [ ! -p "${PIPE_FILE}" ]; then
    echo "Creating FIFO pipe ${PIPE_FILE}"
    mkfifo ${PIPE_FILE}
    
    # Set permissions for the FIFO
    echo "Setting permissions for ${PIPE_FILE}"
    chmod 777 ${PIPE_FILE}
else
    echo "FIFO pipe ${PIPE_FILE} already exists"
fi

# Load the module
echo "Loading Pulseaudio module-pipe-sink module"
pactl load-module module-pipe-sink file=${PIPE_FILE} sink_name=${SINK_NAME} format=${FORMAT} rate=${RATE}

echo "Setting default sink to ${SINK_NAME}"
pactl set-default-sink ${SINK_NAME}

echo "List sinks"
pactl list short sinks

echo "Starting Plexamp"
node ./js/index.js
