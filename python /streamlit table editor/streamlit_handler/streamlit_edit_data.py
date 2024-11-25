# src/streamlit_edit_data.py

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

class StreamlitEditData(StreamlitHandler):
    """
    Class used to facilitate between streamlit app and database functions
    when editing data in the source table.

    Methods
    ----------
    data_editor_formatted()
        returns data_editor widget
    
    update_source_data(edited_data: pandas.DataFrame)
        used to edit data in the source table
    """

    def __init__(self):
        super().__init__()
        
        
    def data_editor_formatted(self):
        """
        Will return a formatted data_editor widget

        Returns
        -------
        streamlit data_editor widget

        """
        # offset = (current_page - 1) * rows per page
        # fetch next = rows per page
        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                          self.rows_per_page,
                                          ))

        return(st.data_editor(data=self.table_data, 
                              key="data_editor_update",
                              use_container_width=True,
                              column_order=self._column_order,
                              ))


    def update_source_data(self, edited_data: pd.DataFrame)-> None:
        """
        Detect changes by comparing the original and edited DataFrames

        Parameters
        ----------
        edited_data : pandas DataFrame
            Will extract out the rows and columns that need to be updated
        """

        if not edited_data.equals(self.table_data):
            # get what has changed
            changes = edited_data.compare(self.table_data)
            for index, row in changes.iterrows():
                # Update only the changed columns for each modified row
                row_id = self.table_data.loc[index, self.primary_key_column_name]
                changed_columns = row.index.get_level_values(0).unique()
                
                # Extract only the changed values to update in the database
                update_data = edited_data.loc[index, changed_columns].to_dict()
                self.data_handler.update_row(table=self._remote_table_name, 
                                             update_data=update_data,
                                             primary_key_column=self.primary_key_column_name, 
                                             row_id=row_id)
            self._query_success = True

