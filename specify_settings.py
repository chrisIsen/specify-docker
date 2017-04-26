
# The webapp server piggy backs on the thick client.
# Set the path to a thick client installation.
THICK_CLIENT_LOCATION = '/opt/Specify'

# Set the database name to the mysql database you
# want to access.
DATABASE_NAME = 'specify6'
DATABASE_HOST = 'db'
DATABASE_PORT = '3306'

# The master user login. Use the same values as
# you did setting up the thick client.
MASTER_NAME = 'ben'
MASTER_PASSWORD = 'ben'

# Select the schema localization language.
SCHEMA_LANGUAGE = 'en'

# The Specify web attachement server URL.
WEB_ATTACHMENT_URL = "http://media:8080/web_asset_store.xml"

# The Specify web attachment server key.
WEB_ATTACHMENT_KEY = 'test_attachment_key'

# The collection name to use with the web attachment server.
WEB_ATTACHMENT_COLLECTION = None

# Set to true if asset server requires auth token to get files.
WEB_ATTACHMENT_REQUIRES_KEY_FOR_GET = False

# Report runner service
REPORT_RUNNER_HOST = 'report'
REPORT_RUNNER_PORT = '8080'

# Workbench uploader log directory.
# Must exist and be writeable by the web server process.
WB_UPLOAD_LOG_DIR = "/tmp/"

# To allow anonymous use, set ANONYMOUS_USER to a Specify username
# to use for anonymous access.
ANONYMOUS_USER = None

# For exception logging using Sentry (https://github.com/getsentry/sentry).
RAVEN_CONFIG = None

# Support login mechanism.
ALLOW_SUPPORT_LOGIN = False
SUPPORT_LOGIN_TTL = 300

STATS_URL = "https://stats.specifycloud.org/capture"
