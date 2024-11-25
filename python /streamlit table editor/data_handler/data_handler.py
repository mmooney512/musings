# data_handler/data_handler.py

# -- LIBRARY -----------------------------------------------------------------
import sqlalchemy.sql.sqltypes as sqltypes
import numpy            as np
import pandas           as pd

# -- LOCAL -------------------------------------------------------------------
from library.pandas_sql_handler import PandasSqlHandler

class DataHandler:
    """
    Class to handle conversion from sql tables to pandas Dataframes
    """

    def __init__(self, db_handler:PandasSqlHandler):
        self.db_handler = db_handler


    def _adjust_dataframe_types(self, df):
        """ Adjusts the DataFrame's data types to be compatible with SQL Server """
        for column in df.columns:
            match df[column].dtype:
                case 'float64':
                    df[column] = df[column].astype('float32')  # Adjust precision if needed
                case 'int64':
                    df[column] = df[column].astype('int32')  # Adjust for SQL Server int handling
                case 'object':
                    df[column] = df[column].astype('str')  # Ensure text data type compatibility                
        return df
    


    def __sql_to_pandas_dtype(self, sql_type:str):
        """converts sql data type to appropirate pandas datatype
        
        Parameters
        ----------
        sql_type : str 
        """
        match sql_type.lower():
            case 'int':
                return np.int32
            case 'varchar':
                return str
            case 'nvarchar':
                return str
            case 'date' | 'datetime' | 'datetime2':
                return 'datetime64[ns]'
            case 'bit':
                return 'bool'
            case _ :
                return object


    def get_table_columns(self, query:str, filter_columns:list, query_params:tuple=None):
        """
        Get the meta data about the table, including the column name
        and sql data type.  The sql data type will be converted to a pandas
        data type.

        Parameters
        ----------
        query : str 
            query used to find the list of columns and data types
        filter_columns : list 
            to filter columns to show to user
        query_params : tuple, optional
            parameters to be inserted into the query
        
        """
        # convert filter_columns to a string
        filter_columns = "','".join(filter_columns)
       
        # get the data frame and apply filter to it
        metadata_df = self.db_handler.read_table(query=query, params=query_params)
        metadata_df = self._adjust_dataframe_types(metadata_df).query(f"COLUMN_NAME in ['{filter_columns}']")
        
        column_info = dict(zip(metadata_df["COLUMN_NAME"],
                               metadata_df["DATA_TYPE"].apply(self.__sql_to_pandas_dtype)
                               ))
        
        return column_info
    
    
    def add_row(self, table_name:str, data: pd.DataFrame):
        """
        Ensure compatible data types for SQL Server before inserting

        Parameters
        ----------
        table_name : str
            The name table to add a row to. Table name should include
            the schema and table name.  i.e
            
            - dbo.my_table_name
            - log.my_other_table

        data : pandas.DataFrame
            Data frame holding the data to be inserted into the source table
        """
        
        if not isinstance(data, pd.DataFrame) or len(data) != 1:
            raise ValueError("row data should be a pandas DataFrame with a single row")
        
        # Pass the row data to the PandasSQLHandler to handle the database insertion
        row_dict = data.iloc[0].to_dict()
        
        # Create an SQL INSERT statement with placeholders
        columns = ', '.join(row_dict.keys())
        placeholders = ', '.join([f":{col}" for col in row_dict.keys()])
        query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        self.db_handler.execute_query(query, row_dict)



    def update_row(self, table:str, update_data:dict, primary_key_column:str, row_id):
        """
        Build an UPDATE query dynamically based on changed column values

        Parameters
        ----------
        table_name : str
            The name table to update row data. Table name should include
            the schema and table name.  i.e
            
            - dbo.my_table_name
            - log.my_other_table

        update_data : dict
           Dictionary holding column name value to be updated in the 
           source table

        primary_key : str
            column name that represents the primary key.

        row_id : any
            The row to be upated.

        """
        # Convert all values to native Python types (e.g., int, str)
        update_data = {key: (value.item() if hasattr(value, 'item') else value) for key, value in update_data.items()}

        row_id = int(row_id)
        set_clause = ", ".join([f"{col} = :{col}" for col in update_data.keys()])
        query = f"UPDATE {table} SET {set_clause} WHERE {primary_key_column} = :row_id"

        # Execute the query with the values for each column and row ID
        params = {**update_data, 'row_id': row_id}
        
        self.db_handler.execute_query(query, params)   


    def delete_row(self, table_name:str, primary_key_column:str, row_id):
        """
        Build a delete query dynamically based on changed column values

        Parameters
        ----------
        table_name : str
            The name table to update row data. Table name should include
            the schema and table name.  i.e
            
            - dbo.my_table_name
            - log.my_other_table

        update_data : dict
           Dictionary holding column name value to be updated in the 
           source table

        primary_key : str
            column name that represents the primary key.

        row_id : any
            The row to be upated.

        """
        query = f"DELETE FROM {table_name} WHERE {primary_key_column} = {row_id}"
        self.db_handler.execute_query(query)
