#! /bin/zsh

echo -e "${1}\n$(du -h --max-depth=0 /mnt/mirrors/$1 | awk '{print $1}')\n$(date +'%Y-%m-%d %H:%M:%S')\n${2}" > /mnt/mirrors/status/${1//\//\-}.log
