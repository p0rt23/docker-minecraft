#!/bin/sh

/opt/minecraft/server-start.sh

trap /opt/minecraft/server-stop.sh SIGINT SIGTERM

sleep 5

tail -f /opt/minecraft/logs/latest.log
