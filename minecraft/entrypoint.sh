#!/bin/sh

/opt/minecraft/server-start.sh

trap /opt/minecraft/server-stop.sh SIGINT SIGTERM

while sleep 1; do
    tmux list-sessions 
done
