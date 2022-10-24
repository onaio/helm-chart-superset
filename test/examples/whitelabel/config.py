import os
import codecs
import yaml

from flask_appbuilder.security.manager import AUTH_OAUTH

#---------------------------------------------------------
# Superset specific config
#---------------------------------------------------------
DEBUG = False
ROW_LIMIT = 5000
SUPERSET_WORKERS = 2

SUPERSET_WEBSERVER_PORT = 8088
#---------------------------------------------------------

#---------------------------------------------------------
# Load decrypted secrets from superset_config.yaml
#---------------------------------------------------------
with codecs.open("/home/superset/superset_config.yaml", encoding="utf-8") as cfg_file:
    cfg = yaml.load(cfg_file, Loader=yaml.FullLoader)
#---------------------------------------------------------

#---------------------------------------------------------
# Flask App Builder configuration
#---------------------------------------------------------

APP_NAME = 'Customized Discover'

# APP_ICON = "/home/superset/assets/images/superset-logo-horiz.png"
# APP_ICON_WIDTH = 126

# FAVICONS = [{"href": "/home/superset/assets/images/favicon.png"}]

# Your App secret key
SECRET_KEY = cfg.get('SECRET_KEY', '\2\1thisismyscretkey\1\2\e\y\y\h')

# ----------------------------------------------------
# AUTHENTICATION CONFIG
# ----------------------------------------------------
# The authentication type
# AUTH_OID : Is for OpenID
# AUTH_DB : Is for database (username/password()
# AUTH_LDAP : Is for LDAP
# AUTH_OAUTH : Is for oAuth
# AUTH_REMOTE_USER : Is for using REMOTE_USER from web server
AUTH_TYPE = AUTH_OAUTH

OAUTH_PROVIDERS = [
  {
    'name': 'onadata',
    'icon': 'fa-sign-in',
    'token_key': 'access_token',
    'remote_app': {
      'client_id': cfg.get("ONADATA_CONSUMER_KEY", ""),
      'client_secret': cfg.get("ONADATA_CONSUMER_SECRET", ""),
      'api_base_url': 'https://api.ona.io/',
      'access_token_url': 'https://api.ona.io/o/token/',
      'authorize_url': 'https://api.ona.io/o/authorize/'
    }
  },
]

# The SQLAlchemy connection string to your database backend
# This connection defines the path to the database that stores your
# superset metadata (slices, connections, tables, dashboards, ...).
# Note that the connection information to connect to the datasources
# you want to explore are managed directly in the web UI
SQLALCHEMY_DATABASE_URI = 'sqlite:////var/lib/superset/superset.db'
if cfg.get('DB_ENGINE'):
    SQLALCHEMY_DATABASE_URI = "%(DB_ENGINE)s://%(DB_USER)s:%(DB_PASS)s@%(DB_HOST)s:%(DB_PORT)s/%(DB_NAME)s?sslmode=disable" % cfg


# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = True
# Add endpoints that need to be exempt from CSRF protection
WTF_CSRF_EXEMPT_LIST = []

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = 'pk.eyJ1Ijoib25hIiwiYSI6ImNrYnoyNnhlYzE1ZTIycnA3aWhhMm8xNmMifQ.O10KB0DNeKUdOwgARXbFlw'

# The allowed translation for you app
LANGUAGES = {
    'en': {'flag': 'us', 'name': 'English'},
    'it': {'flag': 'it', 'name': 'Italian'},
    'fr': {'flag': 'fr', 'name': 'French'},
    'zh': {'flag': 'cn', 'name': 'Chinese'},
    'ja': {'flag': 'jp', 'name': 'Japanese'},
    'de': {'flag': 'de', 'name': 'German'},
    'ru': {'flag': 'ru', 'name': 'Russian'},
    'pt': {'flag': 'pt', 'name': 'Portuguese'},
    'pt_BR': {'flag': 'br', 'name': 'Brazilian Portuguese'},
}

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = 'Public'
# Will allow user self registration
AUTH_USER_REGISTRATION = True
# Set public role like Gamma
PUBLIC_ROLE_LIKE = "Gamma"

# ---------------------------------------------------
# Image and file configuration
# ---------------------------------------------------
# The file upload folder, when using models with files
UPLOAD_FOLDER = "/var/lib/superset/uploads"

# The image upload folder, when using models with images
IMG_UPLOAD_FOLDER = "/var/lib/superset/images"

# CORS Options
ENABLE_CORS = True
CORS_OPTIONS = {
  "origins": "*",
  "methods": "GET,PUT,POST",
  "allow_headers": "Custom-Api-Token",
  "supports_credentials": True
}

# CORS Options
ENABLE_CORS = True
CORS_OPTIONS = {
  "origins": "*",
  "methods": "GET,PUT,POST",
  "allow_headers": "Custom-Api-Token",
  "supports_credentials": True
}
# PATCHUP_EMAIL_BASE

# Allowed format types for upload on Database view
ALLOWED_EXTENSIONS = set(['csv'])

import sys
import superset_patchup

superset_patchup.add_ketchup(sys.modules[__name__])

# Roles that are controlled by the API / Superset and should not be changes
# by humans.
ROBOT_PERMISSION_ROLES = ['Gamma', 'Alpha', 'Admin', 'sql_lab']

# Superset dashboard position json data limit
SUPERSET_DASHBOARD_POSITION_DATA_LIMIT = 262144

#
# Flask session cookie options
#
# See https://flask.palletsprojects.com/en/1.1.x/security/#set-cookie-options
# for details
#
SESSION_COOKIE_HTTPONLY = False  # Prevent cookie from being read by frontend JS?
SESSION_COOKIE_SECURE = True  # Prevent cookie from being transmitted over non-tls?
# Be explicit in allowing embedding superset dashboards in other sites
# Ref: https://github.com/apache/incubator-superset/issues/8382
SESSION_COOKIE_SAMESITE = None  # One of [None, 'Lax', 'Strict']

PREFERRED_URL_SCHEME = 'https'

SENTRY_URI = cfg.get('SENTRY_URI', '')
if SENTRY_URI:
    import sentry_sdk
    from sentry_sdk.integrations.flask import FlaskIntegration

    sentry_sdk.init(
        dsn=SENTRY_URI,
        integrations=[FlaskIntegration()],
        release='0.36.0'
    )

CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_KEY_PREFIX': 'superset_results',
    'CACHE_REDIS_HOST': 'redis-master.discover-partners.svc.cluster.local',
    'CACHE_REDIS_PORT': '6379',
    'CACHE_REDIS_DB': '8',
    'CACHE_REDIS_PASSWORD': cfg.get('CACHE_REDIS_PASSWORD', ''),
}
TABLE_NAMES_CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_KEY_PREFIX': 'superset_table_names',
    'CACHE_REDIS_HOST': 'redis-master.discover-partners.svc.cluster.local',
    'CACHE_REDIS_PORT': '6379',
    'CACHE_REDIS_DB': '8',
    'CACHE_REDIS_PASSWORD': cfg.get('CACHE_REDIS_PASSWORD', ''),
}
THUMBNAIL_CACHE_CONFIG = {
  'CACHE_TYPE': 'null',
  'CACHE_NO_NULL_WARNING': True,
}