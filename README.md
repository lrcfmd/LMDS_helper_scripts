# LMDS helper scripts
This repository contains short shell scripts, and configuration files to help set up simple web apps such as those hosted on the Liverpool Materials Discovery Server.

These scripts can be ran on the same or different machines (either virtual or physical). In our setup uses a reverse proxy for nginx on seperate virtual machines to those which run the web app. This is considered best practice for security and stability reasons (crashing one app will not crash the rest). However if hardware is limitted these scripts will still allow you to deploy nginx and gunicorn to the same virtual machine.


## Setting up Gunicorn process manager
Gunicorn is a process manager which runs apps such as the flask apps used on the LMDS
This Gunicorn provides numerous functions:
* Runs your flask apps
* Manages the number of threads a flask app can use, for better parallelism
* Restarts apps threads if they crash
* Provides robust logging utility
to install gunicorn you can use
```
$ pip install gunicorn
```
[more information can be found here](https://gunicorn.org/)

Gunicorn hooks nicely in to the systemd service utility provided with many linux distros (such as Ubuntu)
systemd allows for processes to be managed by the operating system, and will launch Gunicorn on OS boot or crash

### systemd Gunicorn setup
in the gunicorn_setup/setup_files/ directory you will find three files.
These are the configured for multiple gunicorn apps to be ran from the same machine.
You will need to edit lines 10 and 12 of the gunicorn@.service file to provide the appropriate user and directory information. The directory listed in line 12 is the one which your webapps will end up in the -t argument when running the script to add new webapps detailed bellow

Once you have editted the gunicorn@.service file copy the three files in the `gunicorn_setup/setup_files/` directory to `/usr/lib/systemd`
this can be done with:
```
sudo cp gunicorn_setup/setup_files/* /usr/lib/systemd
```

## Adding new web webapps using Gunicorn
This is can be done using the script gunicorn_setup/add_new_gunicorn_service.sh
This script is designed to be run after installing and configuring gunicorn with
the previously mentioned setup files, it takes in three arguments:
* -s the source folder, this is the folder which contains your flask (or django) app.
* -t the webapp folder, the folder which you contains the webapps (specified on line 12 of the gunicorn@.service during the "systemd Gunicorn setup" section of this manual)
* -p the port this webapp should run on. This should be unique per webapp on a single machine (webapps on different machines can be on the same port)

run this script with
```
$ chmod +x gunicorn_setup/add_new_service.sh #only required the first time
$ . gunicorn_setup/add_new_service.sh
```

This script will require sudo access

## Managing webapps and accessing logs with Gunicorn
For this you will need to remember the port your webapp is running from.
Here are some handy commands you can use to manage your Gunicorn process, look up systemd and systemctl for more information. Remember to replace `port` with the port number of your web app
| Command                                | Function                                       |
| -------------------------------------- | ---------------------------------------------- |
| `systemctl reboot gunicorn@port`       | Reboots process                                |
| `systemctl enable gunicorn@port`       | Enables process (starts on boot)               |
| `systemctl disable gunicorn@port`      | Disables process (will no longer start at boot)|
| `systemctl stop gunicorn@port`         | Stops process                                  |
| `systemctl start gunicorn@port`        | Start process                                  |
| `journalctl -u gunicorn@port`          | Shows log for process                          |
| `journalctl -n 15 -u gunicorn@port`    | Shows last 15 lines of log for process         |
| `journalctl -n 15 -f -u gunicorn@port` | Shows last 15 lines of log for process and follows as new logs are added |


## Setting up nginx
[nginx](nginx.org) is a widely used and powerful HTTP server and reverse proxy server.
We use nginx for the following:
* Directing traffic between different flask webapps (acting as a reverse proxy)
* Handling security certification (https)
* Robust logging
On Ubuntu nginx can be installed with the following
```
$ sudo apt install nginx
```
We provide a sample configuration file for nginx.
Edit the file nginx_setup/setup_files/default to fill in relevant details for your setup_files
Specifically the following lines require attention
* 42, 43: provide ssl certification detail (for https, for this you may need to liase with your university networks department, otherwise look up letsencrypt which will handle this for you)
* 46: allows you to host things statically (for example we host our home page this way)
* 51: Provide details of your domain name
* 63-67: details of further static media (this can be commented out already covered by line 46)
* 69-77: These are examples of websites which are being proxied, you can use these examples as basis or you can use the script detailed later.

This can configuration be copied to the correct directory, and the default package should be symlinked from sites/available to sites enabled. By using symlink (symbolic link, equivalent to window's folder shortcuts) you can edit the file and create backups in the /etc/nginx/sites-available folder, minimally impacting the folder which nginx actually uses for config (which is /etc/nginx/sites-enabled)
```
$ sudo cp nginx_setup/setup_files/nginx.conf /etc/nginx
$ sudo cp nginx_setup/setup_files/default /etc/nginx/sites-available
$ sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
```

## Enabling nginx reverse proxy for new apps.
We provide a script to walk you through enabling nginx reverse proxy for new apps:
```
$ chmod +x nginx_setup/add_new_service_to_nginx_proxy.sh #only needs to be done the first time you run it
$ . nginx_setup/add_new_service_to_nginx_proxy.sh
```

## Managing webapps and accessing logs with Nginx
To remove processes from your nginx proxy simply comment their lines in the /etc/nginx/sites-available/default file and restart nginx as detailed bellow
| Command                                | Function                                       |
| -------------------------------------- | ---------------------------------------------- |
| `service nginx restart`                | Restarts nginx                                 |
| `service nginx stop`                   | Stops nginx                                    |
| `service nginx start`                  | Sarts nginx                                    |
| `cat /var/log/nginx/access.log`        | Displays nginx access log (note this file location can be changed in the /etc/nginx/ninx.conf file) |
| `cat /var/log/nginx/error.log`         | Displays nginx error log  (note this file location can be changed in the /etc/nginx/ninx.conf file) |
| `tail -f /var/log/nginx/access.log`    | Displays a live feed of the nginx access log (note this file location can be changed in the /etc/nginx/ninx.conf file) |
