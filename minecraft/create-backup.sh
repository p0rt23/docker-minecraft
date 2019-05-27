#!/bin/sh

# Get rid of backups older than 7 days:
find /opt/minecraft/backups -type f -mtime +7 -name '*.gz' -exec rm -- '{}' \;

# Turn off server autosaving, and save all data:
tmux send-keys -t minecraft 'say Backup process starting...' C-m 'save-off' C-m 'save-all' C-m
sleep 5

tar -czvf /opt/minecraft/backups/world_$(date '+%Y-%m-%d_%H-%M-%S').tar.gz /opt/minecraft/world

# Turn server autosaving back on:
tmux send-keys -t minecraft 'save-on' C-m 'say Backup complete!' C-m 
