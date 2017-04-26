# Specify Media Server

This is a dockerized version of the sample attachment server implementation from Specify Software.

## Dependencies

Please see the Dockerfile for the deps.

## Usage

Please see the Makefile for usage. 

- Build with `make build`
- Start services with `make up`.
- Do all with `make`
- Release with `make release`

## Specify settings

You can display the suggested Specify 6 configuration settings using:

"make cfg"

The Specify GUI needs to be configured in the Specify 6 desktop client's About dialog: 

"the easiest way to do this is to open the database in Specify and navigate to
the *About* option in the help menu. In the resulting dialog double-click on the
division name under *System Information* on the right hand side. This will open
a properties editor for the global preferences. You will need to set four properties
to configure access to the asset server:"

- `USE_GLOBAL_PREFS` `true`
- `attachment.key`  obtain from asset server `settings.py` file
- `attachment.url`  `http://[YOUR_SERVER]/web_asset_store.xml` 
- `attachment.use_path` `false`

If these properties do not already exist, they can be added using the *Add Property*
button.

## TODO

These Specify 6 settings probably end up in a properties file somewhere? Perhaps it can be automated.
