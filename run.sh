echo "Running as user: $(whoami)"

echo "Starting Pulseaudio"
# pulseaudio -D --verbose --exit-idle-time=-1
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit
# systemctl status --user pipewire-pulse.service

# pacmd load-module module-virtual-sink sink_name=v1

# pactl -help
# pactl list short sinks

echo "Disabling protected fifos"
echo 0 > /proc/sys/fs/protected_fifos
sysctl fs.protected_fifos=0

echo "Creating fifo"

# Use environment variables with defaults
PIPE_FILE=${PIPE_FILE:-/tmp/audio/plexamp_fifo}
SINK_NAME=${SINK_NAME:-Plexamp}
FORMAT=${FORMAT:-s16le}
RATE=${RATE:-48000}

pactl load-module module-pipe-sink file=${PIPE_FILE} sink_name=${SINK_NAME} format=${FORMAT} rate=${RATE}
chmod 777 ${PIPE_FILE}

echo "List sinks"
pactl list short sinks

echo "Starting Plexamp"
node ./js/index.js
