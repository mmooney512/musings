# home.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st
import pandas as pd
import yaml
import os

# -- LOCAL -------------------------------------------------------------------
from library.pandas_sql_handler import PandasSqlHandler
from data_handler.data_handler import DataHandler
from config import sql_column_config


def main():
    st.set_page_config(layout="wide")
    st.title("Database Table Editor")

    st.markdown(
        """
        Select Action and Table to Edit from menu
        """
        )


if __name__ == "__main__":
    main()
