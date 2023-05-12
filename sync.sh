#!/bin/bash
set -ex
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )

STATUS_FOLDER="$THIS_DIR"/status
STATUS_INDEX="$STATUS_FOLDER"/index
touch "$STATUS_INDEX"

presync() {
    local name="$1"
    local log_file="$STATUS_FOLDER"/$name.log
    grep -qxF -- "$name" "$STATUS_INDEX" || echo "$name" >> "$STATUS_INDEX"
    if [[ -f "$log_file" ]]; then
        sed -i "4c syncing..." "$log_file"
        sed -i "3c $(date +'%Y-%m-%d %H:%M:%S')" "$log_file"
    else
        echo -e "${name}\n0\n0\niniting..." > "$log_file"
    fi
}

postsync() {
    local name="$1"
    local status="$2"
    local dst="$3"
    echo -e "${name}\n$(du -h --max-depth=0 "$dst" | awk '{print $1}')\n$(date +'%Y-%m-%d %H:%M:%S')\n${status}" > "$STATUS_FOLDER"/$name.log
}

locked() {
    local name="$1"
    sed -i  '4 s/$/?/' "$STATUS_FOLDER"/$name.log
}

do_sync() {
    local name="$1"
    local src="$2"
    local dst="$3"

    local lock_file="/tmp/mirror-$name.lock"
    if [ ! -f "$lock_file" ];
    then
        touch "$lock_file"
            presync "$name"
            echo rsync -4avzthP --stats --delete --bwlimit=6000 "$src" "$dst"
            postsync "$name" $?
        rm "$lock_file"
    else
        locked "$name"
    fi
}

while read p || [[ -n $p ]]; do
    do_sync $p
done < "$THIS_DIR"/config
