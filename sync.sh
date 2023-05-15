#!/bin/bash
set -ex
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )

STATUS_FOLDER="$THIS_DIR"/status
STATUS_INDEX="$STATUS_FOLDER"/index
touch "$STATUS_INDEX"

presync() {
    local name="$1"
    local log_file="$STATUS_FOLDER"/$name.log
    if [[ -f "$log_file" ]]; then
        sed -i "3c syncing..." "$log_file"
        sed -i "2c $(date +'%Y-%m-%d %H:%M:%S')" "$log_file"
    else
        echo -e "0\n0\niniting..." > "$log_file"
    fi
}

postsync() {
    local name="$1"
    local status="$2"
    local dst="$3"
    echo -e "$(du -h --max-depth=0 "$dst" | awk '{print $1}')\n$(date +'%Y-%m-%d %H:%M:%S')\n${status}" > "$STATUS_FOLDER"/$name.log
}

locked() {
    local name="$1"
    sed -i  '3 s/$/?/' "$STATUS_FOLDER"/$name.log
}

do_sync() {
    if [[ -z "$1" ]]; then
        return
    fi
    local name="$1"
    local safe_name="${name//\//_}"
    local src="$2"
    local dst="$3"

    local lock_file="/tmp/mirror-$safe_name.lock"
    if [ ! -f "$lock_file" ];
    then
        touch "$lock_file"
        presync "$safe_name"
        mkdir -p "$(dirname "$dst")"
        rsync -avzthP --stats --delete --bwlimit=6000 "$src" "$dst"
        postsync "$safe_name" $? "$dst"
        rm "$lock_file"
    else
        locked "$safe_name"
    fi
}

append_index() {
    if [[ -z "$1" ]]; then
        return
    fi
    echo "$1" >> "$STATUS_INDEX"
}

rm "$STATUS_INDEX"
touch "$STATUS_INDEX"
while read p || [[ -n $p ]]; do
    append_index $p
done < "$THIS_DIR"/config

while read p || [[ -n $p ]]; do
    do_sync $p
done < "$THIS_DIR"/config
