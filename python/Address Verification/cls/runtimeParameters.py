import os
from pathlib import Path                    # used for local files
from datetime import datetime

class runtimeParameters:
    """stores the runtime parameters for processing"""
    def __init__(self, user_args, batch=False):
        # passed in from the gui
        self.usr_args = user_args
        self.api_mixed = self.usr_args['api_mixed']
        self.api_create = self.usr_args['api_create']
        self.api_parser = self.usr_args['api_parser']
        self.csv_file_name = self.usr_args['input_file']
        self.csv_output_path = self.usr_args['output_dir']
        self.csv_results_path = self.usr_args['output_dir']

        # if we are doing batch processing do all these steps
        if batch:
            self.file_length = -1
            self.test_mode = False

            self.current_index = 0
            self.start_row = self.usr_args['start_row']
            self.end_row = self.usr_args['end_row']
            self.step_size = 1

            # ensure the file directories and input file are valid
            self.__validate_file_directories()
            self.__set_output_path()

    def __set_output_path(self):
        sub_dir = datetime.now().strftime("%Y-%m-%d.%H%M%S") + "_parts"
        sub_dir = Path(self.csv_output_path + "/" + sub_dir)
        if not os.path.exists(sub_dir):
            os.mkdir(sub_dir)
        self.csv_output_path = sub_dir

    def __set_step_limits(self, adj_start_row=0, adj_ending_row=0):
        """check starting row, ending row, and step adjustments
        starting_row and steps can't exceed file size
        """
        # if the file length is 0 then exit
        # else set the limits on the starting, ending, step
        if self.file_length <= 0:
            print(f"File length: {self.file_length}")
            raise OSError("runtimeParameters::set_step_limits File length <= 0")
        else:
            # check if a value has been set in the usr_args
            if isinstance(self.usr_args, dict):
                # if the value is set make sure we don't exceed file len
                if 'start_row' in self.usr_args.keys():
                    self.start_row = max(0 + adj_start_row, 0 + int(self.usr_args['start_row']))
                    self.start_row = min(self.start_row, self.file_length-1)
            # if the value hasn't been set; set to 0
            else: 
                self.start_row = 0 + adj_start_row
            
            # don't run past the end of the file
            self.end_row = adj_ending_row if adj_ending_row > 0 else self.file_length
            # set the batch size
            self.step_size = min(int(self.usr_args['batch_size']), 50, self.file_length)

        if self.start_row > self.file_length:
            print(f"Starting Row exceeds file length: {self.start_row}")
            raise OSError("Invalid Starting Row")

    def __validate_file_directories(self):
        """Check if the user provided file directories
        and input file is correct
        """
        # #rm if Path(self.csv_file_path).is_dir() == False:
        # #rm   raise OSError("Invalid Input Directory Path")
        if Path(self.csv_file_name).is_file() == False:
            print(f"Input file name: {self.csv_file_name}")
            raise OSError("Invalid file name")
        if Path(self.csv_output_path).is_dir() == False:
            print(f"Output Directory: {self.csv_output_path}")
            raise OSError("Invalid Output Directory Path")

    def set_file_length(self, file_length):
        """set the size of file length
        File length is used to determine row processing steps
        """
        self.file_length = file_length
        if self.file_length <= 0:
            print(f"runtimeParameters::set_file_length File length: {self.file_length}")
            raise OSError("File length <= 0")
        else:
            self.__set_step_limits()

    def set_starting_row(self, starting_row):
        self.__set_step_limits(adj_start_row=starting_row)
        pass

    def set_ending_row(self, ending_row):
        pass

    def set_test_mode(self, test_mode):
        self.test_mode = test_mode
