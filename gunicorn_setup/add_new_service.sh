#!/bin/bash

# From https://stackoverflow.com/questions/42219633/running-two-instances-of-gunicorn

# Specify options to parse
options=":p:s:t:"

# Parse options using getopts
while getopts $options opt; do
  case $opt in
    p) port=$OPTARG;;
    s) source=$OPTARG;;
    t) target=$OPTARG;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

if [ -d "$(pwd)$target/$port" ]
then
    echo "Target directory "$(pwd)/$target/$port" exists. Try a different port or remove the directory"
    exit 1
fi

cp -r $source "$(pwd)/$target/$port"

systemctl enable gunicorn.target 
systemctl start gunicorn.target 

systemctl enable gunicorn@$port
systemctl start gunicorn@$port
echo "Service has been started, stop it with \"systemctl stop gunicorn@$port\""
