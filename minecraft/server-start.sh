#!/bin/sh

# https://www.minecraft.net/en-us/download/server/
# java -Xmx1024 -Xms1024 -jar server.jar nogui

# https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/
cmd="java -Xms2G -Xmx2G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -jar server.jar nogui"

tmux new-session -s minecraft -d "$cmd"
