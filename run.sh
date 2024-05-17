echo "Running as user: $(whoami)"

echo "Starting Pulseaudio"
# pulseaudio -D --verbose --exit-idle-time=-1
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit
# systemctl status --user pipewire-pulse.service

# pacmd load-module module-virtual-sink sink_name=v1

# pactl -help
# pactl list short sinks

echo "Creating fifo"
pactl load-module module-pipe-sink file=/tmp/audio/plexamp_fifo sink_name=Plexamp format=s16le rate=48000
chmod 777 /tmp/audio/plexamp_fifo

echo "Starting Plexamp"
node ./js/index.js