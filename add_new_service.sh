#!/bin/bash

# Specify options to parse
options=":p:s:t"

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

if [ -d "$target/$port" ] 
then
    echo "Target directory "$target/$port" exists. Try a different port or remove the directory" 
    exit 1 
fi

cp -r $source "$target/$port"

systemctl enable gunicorn@$port
systemctl start gunicorn@$port
echo "Service has been started, stop it with \"systemctl stop gunicorn@$port\""

