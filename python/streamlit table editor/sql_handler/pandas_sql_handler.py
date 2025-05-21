# / library / pandas_sql_handler.py

# -- SYSTEM ------------------------------------------------------------------
from typing import Any

# -- LIBRARY -----------------------------------------------------------------
import pandas           as pd
import sqlalchemy       as sql

# -- LOCAL -------------------------------------------------------------------
from config import sql_config

class PandasSqlHandler:
    def __init__(self, environment):
        """Class to run SQL queries against MSFT database
        
        Parameters
        ----------
        None

        Methods
        ----------
        run_query(user_query) -> dataframe
            returns the query results in a list of dictionaries
        """
    
        self._environment:str   = environment
        self._conn_str:str      = self.__assign_conn_str()
        self._conn_url          = sql.engine.URL.create("mssql+pyodbc", query={"odbc_connect": self._conn_str})
        self.engine             = sql.create_engine(self._conn_url)   


    def __assign_conn_str(self) -> str:
        match self._environment.lower():
            case 'dev':
                return sql_config.sql.dev.SQL_DRIVER
            case 'prod':
                return sql_config.sql.prod.SQL_DRIVER
            case _ :
                return sql_config.sql.dev.SQL_DRIVER
            
   
    def read_table(self, query, params=None) -> pd.DataFrame:
        """
        Run the SQL query and return the results in a Pandas dataframe

        Returns
        ----------
        Pandas Dataframe
        """
        return pd.read_sql(sql=query, con=self.engine, params=params)
    
    def execute_query(self, user_query:str, params=None) -> None:
        """
        Run and commit the sql query
        """
        with self.engine.connect() as connection:
            connection.execute(sql.text(user_query), params or {})
            connection.commit()

