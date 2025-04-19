#!/bin/bash

set -e

echo "Running as user: $(whoami)"

echo "Starting Pulseaudio"
# pulseaudio -D --verbose --exit-idle-time=-1
pulseaudio -D -vvvv --exit-idle-time=-1 --system --disallow-exit
# systemctl status --user pipewire-pulse.service

# pacmd load-module module-virtual-sink sink_name=v1

# pactl -help
# pactl list short sinks

echo "Protected fifos status: $(cat /proc/sys/fs/protected_fifos)"

# Use environment variables with defaults
PIPE_FILE=${PIPE_FILE:-./tmp/audio/plexamp.out}
SINK_NAME=${SINK_NAME:-Plexamp}
FORMAT=${FORMAT:-s16le}
RATE=${RATE:-48000}

echo "Creating Pulseaudio FIFO at ${PIPE_FILE}"
# Create the directory if it doesn't exist
mkdir -p $(dirname ${PIPE_FILE})

# Create the FIFO
mkfifo ${PIPE_FILE}

# Load the module
echo "Loading Pulseaudio module-pip-sink module"
pactl load-module module-pipe-sink file=${PIPE_FILE} sink_name=${SINK_NAME} format=${FORMAT} rate=${RATE}

echo "Setting permissions for ${PIPE_FILE}"
chmod 777 ${PIPE_FILE}

echo "Setting default sink to ${SINK_NAME}"
pactl set-default-sink ${SINK_NAME}

echo "List sinks"
pactl list short sinks

echo "Starting Plexamp"
node ./js/index.js
