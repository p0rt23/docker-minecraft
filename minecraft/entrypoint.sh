#!/bin/sh

/opt/minecraft/run-command start

trap "/opt/minecraft/run-command stop" SIGINT SIGTERM

sleep 5

tail -f /opt/minecraft/logs/latest.log& wait
