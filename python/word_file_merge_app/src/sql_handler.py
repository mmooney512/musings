# /src / sql_handler.py

# system library -------------------------------------------------------------
import  sqlite3

# local library --------------------------------------------------------------
from    config.app_config   import AppConfig

class SqlHandler():
    def __init__(self) -> None:
        """Class to run sql queries against sqlite database
        
        Parameters
        ----------
        None

        Methods
        ----------
        
        """
        self._connection            = None
        self._cursor                = None
        self._last_id:      int     = 0
        self._user_query:   str     = None

    def __connect_to_database(self) -> None:
        self._connection = sqlite3.connect(AppConfig.DATABASE.value)
        # For dictionary-like access to rows
        self._connection.row_factory = sqlite3.Row        
        # get a ref to the cursor
        self._cursor = self._connection.cursor()  

    def __format_query(self, number_of_params:int = 0) -> None:
        place_holders = ",".join("?" * number_of_params)
        self._user_query =  self._user_query.format(place_holders)

    def __log_sql_callback(self, sql:str) -> None:
        """When wanting to log the sql queries to the console
        
        Parameters
        ----------
        sql: str
            The sql query that was last executed
        """
        print(f"sql:: {sql}")

    def GetLastId(self) -> int:
        return self._last_id
       
    def insert_query(self, user_query:str, *args, **kwargs) -> None:
        """Executes the query and returns the results
        
        Parameters
        ----------
        user_query: str
            Query text in sqlite format
        """
        self.__connect_to_database()
        if kwargs:
            # self._connection.set_trace_callback(self.__log_sql_callback)
            rows = self._connection.execute(user_query,kwargs)
            
        else:  
            rows = self._connection.execute(user_query,args)
        
        # write to db
        self._connection.commit()   

        # grab the last id of data inserted
        self._cursor.execute('SELECT last_insert_rowid();')
        self._last_id = self._cursor.lastrowid  

        self._connection.close()
        return(rows)  


    def select_query(self, user_query:str, params:list = []) -> list:
        """Executes the query and returns the results
        
        Parameters
        ----------
        user_query: str
            Query text in sqlite format
        params: list optional
            list of parameters to merge into the query text
        """

        # assign the query, to allow for dynamic number of parameters
        self._user_query = user_query
        if params:
            self.__format_query(len(params))
        
        self.__connect_to_database()
        rows = self._cursor.execute(self._user_query,params).fetchall()
        self._connection.close()
        return(rows)
    
    def update_query(self, user_query:str, *args, **kwargs) -> bool:
        """Executes the query and returns true
        
        Parameters
        ----------
        user_query: str
            Query text in sqlite format
        """
        self.__connect_to_database()
        if kwargs:
            self._connection.execute(user_query, kwargs)
        else:   
            self._connection.execute(user_query,args)
        # write to db
        self._connection.commit()   
        self._connection.close()
        return(True)
    
    def delete_query(self, user_query:str, *args, **kwargs) -> bool:
        """Executes the delete query and returns true
        
        Parameters
        ----------
        user_query: str
            Query text in sqlite format
        """
        self.__connect_to_database()
        if kwargs:
            self._connection.execute(user_query,kwargs)
        else:   
            self._connection.execute(user_query,args)  

        # write to db
        self._connection.commit()   
        self._connection.close()
        return(True)
