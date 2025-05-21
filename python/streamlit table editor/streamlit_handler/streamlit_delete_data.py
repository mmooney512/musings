# src/streamlit_delete_data.py

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


class StreamlitDeleteData(StreamlitHandler):
    """
    Class used to facilitate between streamlit app and database functions
    when deleting data from the source table.

    Methods
    ----------
    data_editor_formatted()
        returns data_editor widget
    
    prompt_for_confirmation(rows_selected: int)
        sets flag to put button on page for user confirmation

    delete_source_data(self, delete_data: pd.DataFrame)

    """    
    def __init__(self):
        super().__init__()
        self.deletion_requested = False


    def data_editor_formatted(self):
        """
        Will return a formatted data_editor widget

        Returns
        -------
        streamlit data_editor widget
        """
        # get the source table data
        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                          self.rows_per_page,
                                          ))

        # add column to data set
        self.table_data["Select"] = False
        
        # set the column order
        self._column_order = ('Select',) + self._column_order

        return(st.data_editor(data=self.table_data, 
                              key="data_editor_delete",
                              use_container_width=True,
                              column_order=self._column_order,
                              ))
    
    
    def prompt_for_confirmation(self, rows_selected:int):
        """
        Put a button on page that user needs to click in order
        for the delete action to take place

        Parameters
        ----------
        rows_selected : int 
            number of rows where the select column
            value is true, if the user hasn't selected any thing
            prevent the confirm deletion button from being on the page
        """
        self._query_success     = False
        if rows_selected > 0:
            self.deletion_requested = True
        

    
    def delete_source_data(self, delete_data: pd.DataFrame):
        """
        After user confirms the deletion execute the delete 
        commands against the source database

        Parameters
        ----------
        edited_data : pandas DataFrame
            DataFrame only contains the rows to be deleted.

        """
        self.deletion_requested = False

        # Retrieve selected rows from session state for deletion
        for row_id in delete_data[self.primary_key_column_name]:
            self.data_handler.delete_row(self._source_table_name, 
                                         primary_key_column=self.primary_key_column_name,
                                         row_id=row_id)
        self._query_success = True
    
