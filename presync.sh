#!/bin/zsh

sed -i "4c syncing..." /mnt/mirrors/status/${1//\//\-}.log
sed -i "3c $(date +'%Y-%m-%d %H:%M:%S')" /mnt/mirrors/status/${1//\//\-}.log
