#!/bin/zsh

sed -i  '4 s/$/?/' /mnt/mirrors/status/${1//\//\-}.log
