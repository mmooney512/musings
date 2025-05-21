# /config / app_config.py

# system library --------------------------------------------------------------
from enum import Enum

class AppConfig(Enum):
    # version
    VERSION = "1.1.0"

    DATABASE = 'database/word_file_app.sqlite'
    