#!/bin/bash

container="minecraft-develop"
local_dir="/home/docker/backups/minecraft"
container_dir="/opt/minecraft/world"

# Get rid of backups older than 7 days:
find $local_dir -type f -mtime +7 -name '*.gz' -exec rm -- '{}' \;

# Turn off server autosaving, and save all data:
docker exec $container sh -c "/opt/minecraft/run-command save-off"
sleep 5

docker run \
    --rm \
    --volumes-from $container \
    -v $local_dir:/backup \
    alpine \
    ash -c "cd $container_dir && tar -czvf /backup/${container}_$(date '+%Y-%m-%d_%H-%M-%S').tar.gz ."

# Turn server autosaving back on:
docker exec $container sh -c "/opt/minecraft/run-command save-on"
