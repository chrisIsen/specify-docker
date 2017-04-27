# Dockerized Specify

This repo contains materials to build a system with Specify 6 and 7 using Docker. The system includes a media server and a report server.

![Screenshot](screenshot.png)

## Dependencies

The dependencies are:

1. git, make, docker, docker-compose (v1.8)
1. OpenJDK 8 (JRE)
1. X11 socket for GUI-launch of Specify 6

## Usage

Use "make" to build and bring up the services. 

If running for the first time, the database will be loaded with data from the data.sql file (which the Makefile init target automatically downloads from SRC_DATA which is a demo dataset from Kansas available from GitHub, see the Makefile for details).

The db dump takes a while to load, patience please! In other words, the initial start of the db needs to complete before the ui starts, which "wait-for-it.sh" in the Specify 6 container takes care of (it waits for up to 40 seconds for the db to become available).

### First time login to Specify 6

To login, in Specify 6 GUI, use the relevant user/pass credentials pair at the first login... if you use the demodata, please use "demouser", "demouser" for user/pass credentials and a schema upgrade will run which takes some time, patience please!

If you do not know the credentials and you are an admin, to get to know the credentials, determine the username and password hash  by using the "make get-s6-login" target in the Makefile...

At the login dialogue use "db" for the database server name, "specify6" for the database name and "ben" for the master user, unless you have other settings in your .env-file and in the s6init.sql file...

### Login to Specify 7

Before the first login to Specify 7, first make sure the Specify 6 has updated the demodata schema to the latest Specify version, and then run "make s7-notifications" which adds a table to the databaseschema which is needed specifically by Specify 7 (but not by Specify 6).

Then use the credentials above (normally demouser/demouser) to login at http://specify (normally demouser/demouser)

## Settings files for Specify 6 and Specify 7

Specify 6 stores some settings in local files, such as:

	- /root/Specify/user.properties

The user.properties needs to be updated with minimal settings that can be used on the initial run. This is done automatically in the Makefile init target.

It seems like these entries should be valid, as default settings provided in the user.properties file in this repo:

USE_GLOBAL_PREFS=true
attachment.url=http\://media\:8080/web_asset_store.xml
attachment.use_path=false
attachment.key=test_attachment_key
attachment.path=
login.servers_selected=db
login.dbdriver_selected=MySQL
login.databases_selected=specify6
login.port=3306
login.databases=specify6
login.servers=db
login.rememberuser=false

Specify 7 stores settings in a file called `specify_settings.py`, such as:

- filesystem location of Specify 6 thick client (it needs Specify 6)
- database connection settings
- media server URL and server key
- report server name and port
- traffic stats URL

For specifics, look in that file.

## TODO

- Add database dump and load to Makefile
- Webify Specify 6 so it runs in the browser using github.com/dina-web/inselect-docker techniques...
- Reconfigure app.conf to also route to Specify6 webified
- Add dnsdock, proxy and SSL configs
- Use bob-docker/isobuilder to build a Docker image which has docker-compose and all of this project embedded and push to Docker Hub

- Deploy on a test server and set up SSL and possibly traffic analytics with piwik and uptime etc?
- Create a tutorial outlining steps to load another Specify database, for example from a nightly backup
- On test server - try to use with production db from there - first bring up db with current dump from gnm - then see if we can switch from "db" server to "dina-db.nrm.se"?

Add mysql_config_editor stuff from here:

http://stackoverflow.com/questions/20751352/suppress-warning-messages-using-mysql-from-within-terminal-but-password-written/22933056#22933056

## ISSUES

Clicking the "LifeMapper" button gives an error like "javax.media.opengl.GLException: Profiles [GL4bc, GL3bc, GL2, GLES1] not available on device null", no workaround found for that yet (didn't look either).

