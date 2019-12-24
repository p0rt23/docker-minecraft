#!/bin/sh

# Replace the datapacks folder from the docker image:
rm -rf /opt/minecraft/world/datapacks
cp -r /opt/minecraft/datapacks/ /opt/minecraft/world/

/opt/minecraft/run-command start

trap "/opt/minecraft/run-command stop" SIGINT SIGTERM

sleep 5

tail -F /opt/minecraft/logs/latest.log& wait
