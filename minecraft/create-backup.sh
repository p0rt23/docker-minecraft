#!/bin/bash

find /opt/minecraft -type f -mtime +7 -name '*.gz' -execdir rm -- '{}' \;
/var/opt/server-stop.sh
tar -czvf /opt/minecraft/backups/world_$(date '+%Y-%m-%d_%H-%M-%S').tar.gz /opt/minecraft/world
/var/opt/server-start.sh
