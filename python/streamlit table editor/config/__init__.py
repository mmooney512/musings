# MXP_API / config /__init__.py

# -- SYSTEM ------------------------------------------------------------------
import pathlib, sys

# -- LIBRARY -----------------------------------------------------------------
from box import Box


# ----------------------------------------------------------------------------
# load configuration
# ----------------------------------------------------------------------------
def load_config(file_name: str) -> Box:
    path = pathlib.Path(__file__).parent / file_name
    try: 
        with path.open(mode="r") as config_file:
            return Box(frozen_box=True).from_yaml(config_file.read())

    except FileNotFoundError as e:
        print(f"The directory {path.name} does not exist \n\n {e}")
        sys.exit(1)
    except PermissionError as e:
        print(f"Permission denied to access the directory {path.name}\n\n {e}")
        sys.exit(1)
    except OSError as e:
        print(f"An OS error occurred: {e}")
        sys.exit(1)

    finally:
        path = None

sql_config:Box          = load_config("sql_config.yaml")
sql_column_config:Box   = load_config("sql_column_config.yaml")
streamlit_config:Box    = load_config("streamlit_config.yaml")