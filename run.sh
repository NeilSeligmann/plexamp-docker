pactl load-module module-pipe-sink file=/tmp/snapfifo sink_name=Snapcast format=s16le rate=48000
chmod 777 /tmp/snapfifo
node ./js/index.js