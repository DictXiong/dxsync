#!/bin/zsh

for src in {CTAN,ubuntu,docker-ce/linux/ubuntu,ubuntu-releases}
do
    if [ ! -f "/tmp/mirror-${src//\//\-}.lock" ];
    then
        touch /tmp/mirror-${src//\//\-}.lock
            /home/root/programs/dxsync/presync.sh $src
            rsync -4avzthP --stats --delete --bwlimit=6000 --log-file=/var/log/rsync-mirrors-${src//\//\-}.log rsync://mirrors4.tuna.tsinghua.edu.cn/$src /mnt/mirrors/$src
            /home/root/programs/dxsync/postsync.sh ${src} $?
	rm /tmp/mirror-${src//\//\-}.lock
    else
        /home/root/programs/dxsync/locked.sh $src
    fi
done
