#!/bin/bash

set -e

echo "Running as user: $(whoami)"

echo "--------------------------------"
echo "Pulseaudio version: $(pulseaudio --version)"
# echo "Pulseaudio help:"
# pulseaudio --help
echo "--------------------------------"

# Check if pulseaudio is already running
if pulseaudio --check; then
    echo "Pulseaudio is already running!"
else
    echo "Starting Pulseaudio..."
    # pulseaudio -D --verbose --exit-idle-time=-1
    pulseaudio -D --verbose -vvvv --exit-idle-time=-1 --system --disallow-exit --log-level=debug --log-target=stderr --disable-shm
    echo "Pulseaudio started!"
fi
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
