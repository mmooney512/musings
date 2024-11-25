# src/streamlit_handler.py

# -- LIBRARY -----------------------------------------------------------------
import pandas as pd
import streamlit as st
from datetime import datetime

# -- LOCAL -------------------------------------------------------------------
from config import sql_column_config
from config import streamlit_config
from data_handler.data_handler import DataHandler
from library.pandas_sql_handler import PandasSqlHandler

class StreamlitHandler:
    """
    Class used to facilitate between streamlit app and database functions

    Attributes
    ----------
    primary_key_column_name : str
        name of the primary key column defined in the file 
        config/sql_column_config.yaml

    query : str
        query string to run against source database

    table_data : pandas.DataFrame
        data frame is used to hold the source data values, to allow
        for quick comparision of what data the user has changed 
    
    db_handler : PandasSqlHandler Class
        Instance of the PandasSqlHandler Class

    data_handler : DataHandler
        Instance of the DataHandler Class

    
    Methods
    ----------
    fetch_table_data()
        Loads the data from source table
        
    selectbox_table()
        Creates the streamlit drop down UI element
    
    query_success()
        indicates if the last query run was completed successfully


    """
    def __init__(self, table_name: str = None):
        """
        Attributes
        ----------
        table_name : str
            name of the source table
        """
        # self.active_table:str               = None
        self._base_table_name:str           = ''
        self._column_order:list             = None
        
        self._query_file_name:str           = None
        self._query_success:bool            = False
        self._remote_table_name:str         = None
        self._source_schema:str             = 'dbo'
        self._source_table_name:str         = table_name
        self._total_pages: int              = 1
        
        
        self.current_page:int               = 1
        self.primary_key_column_name:str    = None
        self.query:str                      = None
        self.rows_per_page: int             = 10
        self.table_data: pd.DataFrame       = None
                
        self.db_handler                     = PandasSqlHandler(environment='dev')
        self.data_handler                   = DataHandler(self.db_handler)


    @property
    def source_table_name(self):
        """Source table or view for the query"""
        return self._source_table_name
    
    @source_table_name.setter
    def source_table_name(self, table_name:str):
        self._base_table_name   = table_name.split('.')[1]
        self._query_file_name   = ''.join([table_name,'.sql'])
        self._remote_table_name = table_name
        self._source_table_name = table_name
        self._source_schema     = table_name.split('.')[0]
        self.primary_key_column_name = sql_column_config.table[self._base_table_name].PRIMARY_KEY
    

    @property
    def total_pages(self):
        return self._total_pages

    @total_pages.setter
    def total_pages(self, row_count:int):
        if row_count <= 0:
            self._total_pages = 1
        else:
            self._total_pages = (row_count + self.rows_per_page - 1) // self.rows_per_page 


    def _load_query(self, query_file_name:str = None):
        """
        Read the query file stored in /query directory
        Name of file needs to match the table name which is displayed 
        in the drop down box

        Parameters
        ----------
        query_file_name : str, optional
            name of query file to be loaded in the class if the query name is
            not specified, it is assumed to use a file name of 
            schema.table_name.sql which is assigned in the source_table_name 
            property.
        """
        # if user supplied query_file_name else default val from class
        query_file_name = query_file_name if query_file_name is not None else self._query_file_name

        with open(f"query/{query_file_name}", 'r') as file:
            self.query = file.read()
    

    def __init_table(self):
        pass

    def __set_primary_key_column_name(self) -> None:
        """
        sets the primary key column name defined in the
        config/sql_column_config.yaml file
        """
        self.primary_key_column_name = sql_column_config.table[self._base_table_name].PRIMARY_KEY

    def __set_column_order(self) -> None:
        """
        sets the column order for the data_editor widgets, while excluding
        the primary key column.
        values are defined in the config/sql_column_config.yaml file
        """

        table_columns = list(self.table_data.columns)
        if self.primary_key_column_name in table_columns:
            table_columns.remove(self.primary_key_column_name)
        self._column_order = tuple(table_columns)    
    
    def fetch_row_count(self) -> int:
        """
        Fetch number of rows in the table, used in pagination

        Returns
        -------
        int

        """
        # load the query string
        self._load_query(sql_column_config.info.count.QUERY)
        
        # fetch the row_count data
        data = self.db_handler.read_table(query=self.query,
                                          params=(self.source_table_name,)
                                          )                
        return data.loc[0, 'row_count']

    def fetch_table_data(self,row_params:tuple=None) -> None:
        """Loads the data from source table

        Returns
        -------
        None
        """
        self.__set_primary_key_column_name()
        self._load_query()
        
        self.table_data = self.db_handler.read_table(self.query, row_params)
        
        # set the column order, hiding the primary key column
        self.__set_column_order()
    

    def jump_current_page(self)-> None:
        """
        When user increments, decrements, enters in page number
        move to that page
        """    
        page_input = st.session_state['current_page_input']
        
        if page_input >= 1 and page_input <= self._total_pages:
            self.current_page = page_input

        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                    self.rows_per_page,
                                    ))


    def move_current_page(self, action:str)-> None:
        """
        When user increments, decrements, enters in page number
        move to that page
        """        
        match action:
            case 'decrease':
                if self.current_page > 1:
                    self.current_page -= 1           
            case 'increase':
                if self.current_page < self._total_pages:
                    self.current_page += 1
            case _:
                self.current_page = 1

        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                    self.rows_per_page,
                                    ))    


    def input_page_select(self):
        """
        Creates the streamlit input UI element, limiting to number of pages

        Returns
        -------
        streamlit.selectbox

        """
        # make sure we don't exceed max number of pages
        if self.current_page >= self.total_pages:
            self.current_page = int(self.total_pages)

        return(st.number_input(
                "Go to page",
                min_value=1,
                max_value=self.total_pages,
                value=self.current_page,
                step=1,
                key="current_page_input",
                on_change=self.jump_current_page,
            ))


    def page_nav_controls(self):
        """
        Creates the streamlit input UI elments for page navigation
        Returns
        -------
        streamlit.selectbox        
        """
        with st.container(key='page-controller', border=True):
            col1, col2, col3, col4, col5 = st.columns([1, 2, 1, 1, 4],
                                                vertical_alignment="bottom"
                                                )
        with col1:
            page_nav_label = st.markdown('<p style="font-size:1.3rem;">Page</p>', unsafe_allow_html=True)

        with col2:
            page_nav_page_info = st.markdown(f'<p style="font-size:1.3rem;">{self.current_page} of {self.total_pages}</p>', unsafe_allow_html=True)
            
        with col3:
            page_nav_prior_page = st.button(label="&lt;&lt;",
                 type="secondary", 
                 disabled=(self.current_page <= 1),
                 on_click=self.move_current_page,
                 args=('decrease',)
                 )
             
        with col4:
            page_nav_next_page = st.button(label="&gt;&gt;",
                 type="secondary", 
                 disabled=(self.current_page >= self.total_pages),
                 on_click=self.move_current_page,
                 args=('increase',)
                 )
        
        with col5:
            # intentionally left the column empty  
            page_nav_empty = st.empty()  # just a spacer column

        # return the page_nav controls
        return (page_nav_label, 
                page_nav_page_info, 
                page_nav_prior_page,
                page_nav_next_page,
                page_nav_empty
                )


    def selectbox_rows_per_page(self):
        """
        Creates the streamlit drop down UI element, based on the table
        names stored in the /config/sql_column_config.yaml file

        Returns
        -------
        streamlit.selectbox

        """
        return (st.selectbox(label="Rows per Page:",
                             options=streamlit_config.selectbox.rows_per_page.OPTIONS,
                             index=0,
                             on_change=self.update_rows_per_page,
                             key="rows_per_page",
                             ))

    def selectbox_table(self):
        """
        Creates the streamlit drop down UI element, based on the table
        names stored in the /config/sql_column_config.yaml file

        Returns
        -------
        streamlit.selectbox

        """
        table_options = [f"{sql_column_config.table[tbl].SCHEMA}.{sql_column_config.table[tbl].NAME}" for tbl in sql_column_config.table]

        with st.container():
            col_left, col_mid, col_right = st.columns([4,4,4])
            with col_left:
                select_box_table = st.selectbox(label="Select a table to edit:",
                                                options=table_options,
                                                index=None,
                                                placeholder='Select a Table',                             
                                                )
            with col_mid:
                # intentionally left the column empty
                st.empty()
            with col_right:
                # intentionally left the column empty
                st.empty()

        return (select_box_table)
    
    def query_success(self):
        """
        Returns
        -------
        boolean
            indicates if the last query run was completed successfully
        """
        return(self._query_success)
    
    def update_rows_per_page(self) -> None:
        """
        Update number of rows per page to return
        """
        self.rows_per_page = st.session_state['rows_per_page']



