#!/bin/bash

tmux send-keys -t minecraft 'say SERVER SHUTTING DOWN. Saving map...' C-m 'save-all' C-m 'stop' C-m
sleep 5
