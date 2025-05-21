# /config / flask_app.py

# system library --------------------------------------------------------------
import os, platform
from enum import Enum

class FlaskOptions(Enum):
    # Used to connect to sqlite3 database
    SESSION_TYPE = "sqlalchemy"
                                
    SESSION_SQLALCHEMY_TABLE = 'sessions'

    #port to run flask on
    API_PORT_DEBUG ="7000"
    API_PORT_TEST = "7001"
    API_PORT_PROD = "7002"

