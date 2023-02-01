#!/usr/bin/env bash

while :
do
    nc -l -p 19988 | xclip -i -selection clipboard
done
