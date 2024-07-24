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
pactl load-module module-pipe-sink file=/tmp/audio/plexamp_fifo sink_name=Plexamp format=s16le rate=44100
chmod 777 /tmp/audio/plexamp_fifo

echo "List sinks"
pactl list short sinks

echo "Starting Plexamp"
node ./js/index.js
