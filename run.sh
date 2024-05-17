echo "Starting Pulseaudio"
pulseaudio -D --verbose --exit-idle-time=-1
# systemctl status --user pipewire-pulse.service

# pacmd load-module module-virtual-sink sink_name=v1

# pactl -help
# pactl list short sinks

# ls -la /tmp/snapfifo
echo "Creating fifo"
pactl load-module module-pipe-sink file=/tmp/snapfifo sink_name=Snapcast format=s16le rate=48000
chmod 777 /tmp/snapfifo

echo "Starting Plexamp"
node ./js/index.js