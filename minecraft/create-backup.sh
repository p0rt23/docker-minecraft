#!/bin/sh

find /opt/minecraft/backups -type f -mtime +7 -name '*.gz' -exec rm -- '{}' \;

/opt/minecraft/server-stop.sh

tar -czvf /opt/minecraft/backups/world_$(date '+%Y-%m-%d_%H-%M-%S').tar.gz /opt/minecraft/world

/opt/minecraft/server-start.sh
