import numpy as np
import pandas as pd

class csvFileHandler:
    def __init__(self, usr_args):
        self.csv_df = None
        self.file_len = 0
        self.usr_args = usr_args

    def __add_uid(self):
        """add unique id to the source file"""
        # add new column prepend five zeros
        self.csv_df['uid'] = np.arange(len(self.csv_df))

    def __check_columns(self):
        """make sure the user supplied columns are provided"""
        if {self.usr_args['street']
            , self.usr_args['city']
            , self.usr_args['state']
            , self.usr_args['zip']}.issubset(self.csv_df.columns):
            pass
        else:
            raise OSError("csvFileHandler::__check_columns invalid column names")

    def get_file(self, csv_file_name, test_mode=False):
        if test_mode == True:
            self.csv_df = pd.read_csv(csv_file_name
                                      ,nrows=10)
        else:
            self.csv_df = pd.read_csv(csv_file_name, dtype=np.str)
        # add unique id to dataframe
        self.__add_uid()

        # how many rows in the dataframe
        self.file_len = len(self.csv_df)

        # check if there is an error or blank file
        if self.file_len < 1:
            print(f"Query File {csv_file_name} is empty")
            raise SystemExit
        else:
            # print(f"{self.file_len} Rows in {csv_file_name}")
            pass

        # run the column check
        self.__check_columns()
