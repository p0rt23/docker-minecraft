#!/bin/bash

container="minecraft-develop"
local_dir="/home/docker/backups/minecraft"
container_dir="/opt/minecraft/world"

docker exec $container sh -c "/opt/minecraft/run-command server-stop"
docker exec $container sh -c "rm -rf $container_dir/*"

docker run \
    --rm \
    --volumes-from $container \
    -v $local_dir:/backup \
    alpine \
    ash -c "cd $container_dir && tar xvzf /backup/$1"

docker exec $container sh -c "/opt/minecraft/run-command server-start"
