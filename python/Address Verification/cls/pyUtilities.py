from datetime import datetime
import fnmatch
import os
import pandas as pd
import numpy as np
from pathlib import Path                    # used for local files

class mergeCsvFiles:
    """Read in the .csv files, use pandas to put them into
    one data frame and save the data frame
    """
    def __init__(self):
        # set the default values
        self.file_extension = ".csv"
        self.input_dir = os.getcwd()
        self.output_dir = "./csv_merge"
        self.output_file = None

    def merge_files(self, input_dir=None, output_dir=None, output_file=None):
        # reset the input dir
        if input_dir is not None:
            self.input_dir = input_dir

        # reset the output dir
        if output_dir is not None:
            self.output_dir = output_dir

        # reset the output file
        if output_file is not None:
            self.output_file = output_file
        else:
            self.output_file = str(self.input_dir).replace("_parts", "")
            self.output_file = self.output_file + "_results.csv"

        # change to working directory
        os.chdir(self.input_dir)

        # get the list of file names
        all_filenames = fnmatch.filter(os.listdir(self.input_dir), '*.csv')

        # sort the filename list; reasonably fast since list isn't too big
        all_filenames.sort()

        # combine all files in the list
        combined_csv = pd.concat([pd.read_csv(f, dtype=np.str) for f in all_filenames])

        # export to csv
        combined_csv.to_csv(Path(self.output_file)
                            , index=False, encoding='utf-8-sig')
