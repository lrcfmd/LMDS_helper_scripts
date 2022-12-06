# LMDS helper scripts
This repository contains short shell scripts to help set up simple web apps such as those hosted on the Liverpool Materials Discovery Server.

These scripts can be ran on the same or different machines (either virtual or physical). In our setup uses a reverse proxy for nginx on seperate virtual machines to those which run the web app. This is considered best practice for security and stability reasons (crashing one app will not crash the rest). However if hardware is limitted these scripts will still allow you to deploy nginx and gunicorn to the same virtual machine.

## add_new_gunicorn_service.sh
This script is designed to be run after setup gunicorn.sh, it takes in three arguments:
* -s the source folder, this is the folder which contains your flask (or django) app.
* -t the webapp folder, the folder which you contains the webapps (specified during the setup gunicorn script)
* -p the port this webapp should run on. This should be unique per webapp on a single machine (webapps on different machines can be on the same port)
