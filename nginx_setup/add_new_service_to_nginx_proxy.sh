#!/bin/bash

# Prompt the user for the text that they want to insert
read -p "What is the IP address of the machine on which the webapp is running (if it is running on this machine please enter 127.0.0.1): " ip

ip_regex="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
if grep -Evq "$ip_regex" <<< "$ip"; then
    echo "Was not given a valid IP address, please try again"
    exit 1
fi

read -p "What port was the webapp running on?" port

if !  [[ "$port" -gt 0 && "$port" -lt 65536 ]]; then
    echo "Invalid port number"
    exit 1
fi

read -p "Enter address after the slash for example if I wanted to launch lmds.liv.ac.uk/MOF_ML I would enter \"MOF_ML\"" directory

answer=""
while [[ "$answer" != "y" && "$answer" != "n" ]]; do
    read -p "Is your nginx config in the default directory (/etc/nginx/sites-available/default)  (y/n)?" answer

  if [[ "$answer" == "y" ]]; then
    nginx_config="/etc/nginx/sites-available/default"
  elif [[ "$answer" == "n" ]]; then
    # Do something if the user answered "n"
    read -p "Please enter the address of your nginx config" nginx_config
  else
    echo "Please answer 'y' for yes or 'n' for no."
  fi
done

text="    location /$directory {\n        proxy_pass http://$ip:$port/;\n    }\n"
current_date=$(date +"%d.%m.%Y")
backup_location="$nginx_config.bak.$current_date"
echo "creating backup of current config at $backup_location"
sudo cp $nginx_config $backup_location
echo "adding following text to nginx config:"
echo $text
# Use sed to insert the text after the specified pattern
sed_match="\|location /static|i $text"
sudo sed -i "$sed_match" $nginx_config

sudo service nginx restart
