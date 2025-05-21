# src/streamlit_add_data.py

# -- LIBRARY -----------------------------------------------------------------
import pandas as pd
import streamlit as st
from datetime import datetime
# -- LOCAL -------------------------------------------------------------------
from config import sql_column_config
from config import streamlit_config
from data_handler.data_handler import DataHandler
from library.pandas_sql_handler import PandasSqlHandler
# -- BASE CLASS --------------------------------------------------------------
from .streamlit_handler import StreamlitHandler




class StreamlitAddData(StreamlitHandler):
    """
    Class used to facilitate between streamlit app and database functions
    when adding data to the source table.

    Methods
    ----------
    fetch_empty_table(table_name: str)
        returns an empty data_editor widget
    
    add_source_data(new_data: pandas.DataFrame)
        used to insert data into the source table
    """

    def __init__(self):
        super().__init__()
        self.other: str = None
        self._meta_query_file_name = ''.join([sql_column_config.info.columns.QUERY,'.sql'])
        self._load_query(self._meta_query_file_name)

    def _init_add_data(self):
        """place holder not required"""
        pass
    
    def fetch_empty_table(self, table_name:str = None):
        """
        Create an empty data_editor widget with appropriate columns for
        user to input data to be inserted into the source table

        Parameters
        ----------
        table_name : str
            Name of source table

        Returns
        -------
        streamlit data_editor

        """
        query_params = (self._source_schema, self._base_table_name,)

        column_info = self.data_handler.get_table_columns(
            query=self.query,
            filter_columns=sql_column_config.table[self._base_table_name].COLUMNS,
            query_params=query_params
            )
        
        data = pd.DataFrame({column_name: pd.Series(dtype=column_type) for column_name, column_type in column_info.items()})
    
        return(st.data_editor(data=data,
                              num_rows="dynamic",
                              use_container_width=True
                              ))
    
    def add_source_data(self, new_data: pd.DataFrame):
        """
        Add new rows to the source

        Parameters
        ----------
        table_name : pandas DataFrame
            DataFrame will hold data to be inserted in to the source table
        """
        for row_ctr in range(0, new_data.shape[0]):
            self.data_handler.add_row(self.source_table_name,
                                      new_data.loc[[row_ctr]]
                                      )
        self._query_success = True



