# ----------------------------------------------------------------------------
# Connect to locus API and query the api for
# location id based on provided address info
# uses multiple threads to make requests to the API
# maximum of 8 threads at a time
# each thread by default will send a batch of 50 addresses to the API
#
# Input:    .csv file with physical address info
#           REQUIRED: street, city, state, postal code
# Output    .csv merges api data with source
#           appending api data in right most columns
# DATE:     01 Dec 2019
# UPDATED:  07 Jan 2020
# Rev:      1.2.1
# ----------------------------------------------------------------------------
import concurrent.futures as cf             # used for multi-threaded
from datetime import datetime
import time                                 #
import os
from pathlib import Path                    # used for local files
import numpy as np                          # used for range operations
import pandas as pd                         # used for data frames
from pandas.io.json import json_normalize   # moving json data in/out data frame
import json                                 # json data from API
import requests                             # used for web requests / API calls
import tkinter as tk
from tkinter import messagebox

# ----------------------------------------------------------------------------
# import class files
# ----------------------------------------------------------------------------
from cls.apiHandler import apiHandler
from cls.csvFileHandler import csvFileHandler
from cls.ui import Application
from cls.outputFile import outputFile
from cls.pyUtilities import mergeCsvFiles
from cls.runtimeParameters import runtimeParameters
from cls.userAddresses import userAddresses


logfile = Path(os.getcwd() + "/logs/" + datetime.now().strftime("%Y-%m-%d.%H%M%S") + "_json_request.log")

def process_csv_file(args: runtimeParameters
                     , cfh: csvFileHandler
                     , cidx: int):
    """function to do the locus API calls"""
    # counter to track requests sent to api
    max_tries = 4
    current_index = cidx

    # start retry loop
    for retry_attempts in range(max_tries):
        if app.continue_processing == False:
            return
        # write status to gui window
        app.update_progress(f"Current index == {current_index} retry attempt: {retry_attempts}")
        app.update_row(f"{str(current_index)}")

        # don't reset / re-run if there was an error
        if retry_attempts == 0:
            # prep the user addresses
            # df_curr is the current data frame range to process
            df_curr = cfh.csv_df.iloc[current_index:(current_index + args.step_size)]

            usr_addr = userAddresses(raw_df=df_curr, args=args)
            usr_addr.selectDataColumns()
            usr_addr.prepAddressess()
            usr_addr.populateAddresses()
            # --- DEBUG --- view the json formatted addresses
            # print(usr_addr.json_addresses)
            # --- LOG -- json request
            # append to file, + if file not there create
            with open(logfile, 'a+') as file_handle:
                file_handle.write(usr_addr.json_addresses + "\n")
                file_handle.close()

            # make API calls
            api = apiHandler(api_url=args.usr_args['api_url']
                             , api_key=args.usr_args['api_key'])

        api.sendRequest(usr_addr.json_addresses)

        # initiate the output file handler
        outf = outputFile(file_len=args.file_length
                          , output_path=args.csv_output_path)
        outf.parse_file(current_index, api.json_response
                        , df_curr, df_curr['uid'].tolist())

        if outf.success == True:
            # exit the loop
            break
        else:
            # sleep between retries to see if retry will work
            time.sleep(1.5)

    # exit the for loop
    args.current_index = args.current_index + args.step_size

    # compose result message
    result_msg = f"complete = {str(outf.success)} using {str(retry_attempts)} retry attempts"

    # implicity destroy local var to help with gc
    outf = None
    usr_addr = None
    api = None
    df_j = None
    r_val = None
    df_v = None
    df_output = None

    # momentary pause don't over load pitney bowes
    time.sleep(0.5)
    return result_msg


def start_job(user_args: dict):
    """f(x) to initiate & control the API request threads"""
    try:
        global logfile

        # execution
        app.update_progress("Starting Job")

        # --------------------------------------------------------------------
        # set the run time parameters
        # --------------------------------------------------------------------
        args = runtimeParameters(user_args, batch=True)

        # --------------------------------------------------------------------
        # check and set logfile locale, write log file to results directory
        # --------------------------------------------------------------------
        log_path = Path(args.usr_args['output_dir'] + '/logs/')
        if not log_path.is_dir():
            os.mkdir(log_path)
        nm = logfile.name
        logfile = Path(log_path / nm)

        with open(logfile, 'a+') as file_handle:
            file_handle.write("starting job: " + datetime.now().strftime("%Y-%m-%d.%H%M%S") + "\n")
            file_handle.close()

        # --- DEBUG --- view df
        # print(cfh.csv_df.head(5)

        # initiate file handler to read the input file
        cfh = csvFileHandler(args.usr_args)

        # load the .csv file into a panda data frame
        # rm # cfh.get_file(args.csv_file_name, args.test_mode)
        cfh.get_file(csv_file_name=args.usr_args['input_file'])
        app.update_progress(f"File Length: {len(cfh.csv_df)}")

        # set the run time argument for file size
        # and starting rows, ending rows, and rows to process in batch
        args.set_file_length(len(cfh.csv_df))

        # multi thread the process_csv_file f(x)
        # to initiate multiple threads
        # loop through input source document in groups specified by step size
        with cf.ThreadPoolExecutor(max_workers=8) as executor:
            call_locus_api = {executor.submit(process_csv_file, args, cfh, curr_idx):
                             curr_idx for curr_idx in np.arange(args.start_row, args.end_row, args.step_size)}
            for worker in cf.as_completed(call_locus_api):
                # stop new threads from being processed,
                # won't prevent existing results from being processed
                if app.continue_processing == False:
                    executor.shutdown(wait=False)
                    worker.cancel()
                    break
                fx_result = call_locus_api[worker]
                try:
                    worker_result = worker.result()
                except Exception as e:
                    print(f"Exception {e}")
                    app.update_progress(f"{fx_result} raised an exception {e}")
                else:
                    app.update_result(f"{fx_result} result: {worker_result}")

        # finished processing the file
        # merge the files into one csv
        app.update_result(f"merging csv files")
        mf = mergeCsvFiles()
        mf.merge_files(input_dir=args.csv_output_path, output_dir=args.csv_results_path)

        # finale!
        app.update_result(f"complete")

    except OSError as err:
        print("OS error: {0}".format(err))
        app.update_progress("OS error: {0}".format(err))

    except Exception as e:
        print(f"UNCAUGHT EXCEPTION: {e}")
        app.update_progress(f"UNCAUGHT EXCEPTION: {e}")

def start_grid_job(user_args: dict):
    print("starting grid job")
    app.update_grid_result("Starting Grid Job")

    args = runtimeParameters(user_args, batch=False)

    # populate the address for processing
    usr_addr = userAddresses(raw_df=user_args['grid_df'], args=args)
    usr_addr.selectDataColumns()
    usr_addr.prepAddressess()
    usr_addr.populateAddresses()

    # send the address to the API

    # make API calls
    api = apiHandler(api_url=args.usr_args['api_url']
                     , api_key=args.usr_args['api_key'])
    api.sendRequest(usr_addr.json_addresses)

    # output the api response to the window
    str_json = json.dumps(api.json_response, indent=4)
    app.update_grid_result(str_json)

    print("grid job finished")

# main entry point to start the gui
if __name__ == '__main__':
    # load the gui
    root = tk.Tk()
    app = Application(app_root=root)
    # start the gui
    app.mainloop()
    print("complete")
