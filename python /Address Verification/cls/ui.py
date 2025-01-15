import json                     # read and write config file in json format
import os
import os.path                  # check if files exist
import pandas as pd
import tkinter as tk
from pathlib import Path        # used for local files
from tkinter import messagebox
from tkinter import ttk
from tkinter.filedialog import askopenfilename, askdirectory
import threading as th

# ----------------------------------------------------------------------------
# import class files
# ----------------------------------------------------------------------------
from cls.uiConfig import uiConfig

import __main__

class Application(ttk.Frame):
    def __init__(self, app_root):
        super().__init__(app_root)

        self.app_root = app_root
        # ---- set ui globals ----------------------

        # used as flag to interrupt the processing
        self.continue_processing = False

        # if the window is resized, frame should take up
        # the remaining space
        self.app_root.columnconfigure(0, weight=1)
        self.app_root.rowconfigure(0, weight=1)

        self.app_root.title('Locus API Address Check')
        self.app_root.geometry("780x320")

        # add menu to main window
        self.__addtopmenu()

        # add frames to main window
        self.__addframes()

        # add the gui widgets to the main frame
        self.__drawwidgets()

        # add the message widgets to the main frame
        self.__drawwidgetsmessage()

        # config used to hold run time parameters
        # loads into config dict default values
        # will populate default values on the ui
        self.options = uiConfig(self)
        self.options.loadconfigfile(initial=True)

    def __opt_getconfigfile(self):
        self.options.getconfigfile()

    def __opt_saveconfigfile(self):
        self.options.saveconfigfile()

    def __addtopmenu(self):
        """create the top level menu on the gui"""
        # create a menubar object
        menubar = tk.Menu(self.app_root)

        # create cascading menus
        filemenu = tk.Menu(menubar, tearoff=0)

        # add the commands to the menu
        filemenu.add_command(label="Load Config File", command=self.__opt_getconfigfile)
        filemenu.add_command(label="Save Config File", command=self.__opt_saveconfigfile)
        filemenu.add_separator()
        filemenu.add_command(label="Exit", command=self.app_root.quit)

        # attach the commands to the menu
        menubar.add_cascade(label="File", menu=filemenu)

        # display the menu
        self.app_root.config(menu=menubar)

    def __addframes(self):
        """use a themed frame so background colors work"""
        self.mainframe = ttk.Frame(self.app_root, padding="3 3 12 12")
        self.mainframe.grid(column=0, row=0, sticky=(tk.N, tk.W, tk.E, tk.S))

        self.ttk_notebook = ttk.Notebook(self.mainframe)
        self.options_frame = ttk.Frame(self.ttk_notebook)
        self.output_field_frame = ttk.Frame(self.ttk_notebook)
        self.process_frame = ttk.Frame(self.ttk_notebook)
        self.message_frame = ttk.Frame(self.ttk_notebook)
        self.grid_entry_frame = ttk.Frame(self.ttk_notebook)

    def __drawwidgets(self):
        self.options_frame.config(width=250,height=250)
        self.ttk_notebook.add(self.options_frame, text="Options")
        self.ttk_notebook.add(self.output_field_frame, text="Output Fields")
        self.ttk_notebook.add(self.process_frame, text="Process")
        self.ttk_notebook.add(self.message_frame, text="Messages")
        self.ttk_notebook.add(self.grid_entry_frame, text="Grid Entry")
        self.ttk_notebook.grid(row=0, column=0, padx=10, pady=10)

        self.__drawwidgetsoptions()
        self.__drawwidgetsoutfields()
        self.__drawwidgetsprocess()
        self.__drawwidgetsgridentry()

    def __drawwidgetsoptions(self):
        # --- API -------------------
        # bool choices
        bool_choices = ['true' , 'false']

        # api website options
        url_choices = ['https://oa.verizon.com:9004/locusaddressapi/api/address/getByAddress'
                        , 'https://oa-uat.ebiz.verizon.com/locusaddressapi/api/address/getByAddress']

        # apisite - label
        apiurl_label = ttk.Label(self.options_frame, text='API URL', font=('bold', 12))
        apiurl_label.grid(row=10, column=0, sticky=tk.W, padx=20, pady=(10,0))

        # api - choice

        self.apiurl_text = tk.StringVar()
        self.apiurl_text.set(url_choices[0])
        apiurl_option = ttk.OptionMenu(self.options_frame, self.apiurl_text, url_choices[0], *url_choices)
        apiurl_option.config(width=90)
        apiurl_option.grid(row=10, column=1, columnspan=6, sticky=tk.W, padx=3, pady=(10,0))

        # ------ ROW 20 ------
        # apikey - label
        apikey_label = ttk.Label(self.options_frame, text='API Key', font=('bold', 12))
        apikey_label.grid(row=20, column=0, sticky=tk.W, padx=20)
        # apikey - textbox
        self.apikey_text = tk.StringVar()
        apikey_entry = ttk.Entry(self.options_frame, width=36, textvariable=self.apikey_text)
        apikey_entry.grid(row=20, column=1, columnspan=3, sticky=tk.W, padx=8)


        # ------ ROW 30 ------
        # api option 1 - label
        apimixed_label = ttk.Label(self.options_frame, text='API Mixed Case', font=('bold', 12))
        apimixed_label.grid(row=30, column=0, sticky=tk.W, padx=20)

        self.apimixed_text = tk.StringVar()
        self.apimixed_text.set(bool_choices[0])
        apimixed_option = ttk.OptionMenu(self.options_frame, self.apimixed_text
                                         , bool_choices[1], *bool_choices)
        apimixed_option.config(width=90)
        apimixed_option.config(state="disabled")
        apimixed_option.grid(row=30, column=1, columnspan=6, sticky=tk.W, padx=3)

        # ------ ROW 40 ------
        # api option - label
        apicreate_label = ttk.Label(self.options_frame, text='API Create', font=('bold', 12))
        apicreate_label.grid(row=40, column=0, sticky=tk.W, padx=20)

        self.apicreate_text = tk.StringVar()
        self.apicreate_text.set(bool_choices[0])
        apicreate_option = ttk.OptionMenu(self.options_frame, self.apicreate_text
                                          , bool_choices[0], *bool_choices)
        apicreate_option.config(width=90)
        apicreate_option.grid(row=40, column=1, columnspan=6, sticky=tk.W, padx=3)

        # ------ ROW 50 ------
        # api option - label
        apiparser_label = ttk.Label(self.options_frame, text='API Parser', font=('bold', 12))
        apiparser_label.grid(row=50, column=0, sticky=tk.W, padx=20)

        parser_choices = ['default', 'google', 'spectrum']
        self.apiparser_text = tk.StringVar()
        self.apiparser_text.set(parser_choices[0])
        apiparser_option = ttk.OptionMenu(self.options_frame, self.apiparser_text
                                          , parser_choices[0], *parser_choices
                                          , command=self.updatebatchsize)
        apiparser_option.config(width=90)
        # apiparser_option.config(state="disabled")
        apiparser_option.grid(row=50, column=1, columnspan=6, sticky=tk.W, padx=3)

        # ------ ROW 60 ------
        # batch size - label
        batchsize_label = ttk.Label(self.options_frame, text='Batch Size', font=(None, 12))
        batchsize_label.grid(row=60, column=0, sticky=tk.W, padx=20)

        self.batchsize_text = tk.StringVar()
        batchsize_entry = ttk.Entry(self.options_frame, textvariable=self.batchsize_text, state="disabled")
        batchsize_entry.grid(row=60, column=1, sticky=tk.W, padx=3)


    def __drawwidgetsoutfields(self):
        # output fields - label
        output_field_label = tk.Label(self.output_field_frame, text='Output Fields', font=('bold', 12))
        output_field_label.grid(row=10, column=0, columnspan=2, sticky=tk.W, padx=5, pady=(10,0))

        # output fields - listbox
        self.output_field_list = tk.Listbox(self.output_field_frame, height=10, width=110, border=1)
        self.output_field_list.grid(row=20, column=0, columnspan=3, rowspan=6, padx=5, pady=(10,0))

    def __drawwidgetsprocess(self):
        # ------ BUTTONS --------------
        # ------ ROW 10 ------
        # start button
        start_button = ttk.Button(self.process_frame, text="Start"
                                  , width=12, command=self.start_app)
        start_button.grid(row=10, column=0, padx=5, pady=(10, 10))

        # clear button
        clear_button = ttk.Button(self.process_frame, text="Clear"
                                  , width=12, command=self.clear_progress_message)
        clear_button.grid(row=10, column=1, pady=(10, 10))

        # cancel button
        cancel_button = ttk.Button(self.process_frame, text="Cancel"
                                        , width=12, command=self.cancel_app)
        cancel_button.grid(row=10, column=4, pady=(10, 10))

        # ------ FILE --------------
        # ------ ROW 20 ------
        # inputfile - label
        inputfile_label = ttk.Label(self.process_frame, text='Input File', font=('bold', 12))
        inputfile_label.grid(row=20, column=0, sticky=tk.W, padx=5)

        # inputfile - button
        input_button = ttk.Button(self.process_frame, text="...", width=2, command=self.set_input_file)
        input_button.grid(row=20, column=1, sticky=tk.W)

        # inputfile - textbox
        self.inputfile_text = tk.StringVar()
        inputfile_entry = ttk.Entry(self.process_frame, width=80, textvariable=self.inputfile_text)
        inputfile_entry.grid(row=20, column=1, columnspan=6, sticky=tk.W, padx=30)

        # ------ ROW 50 ------
        # outputdir - label
        outputdir_label = ttk.Label(self.process_frame, text='Output Directory', font=('bold', 12))
        outputdir_label.grid(row=30, column=0, sticky=tk.W, padx=5)

        # outputdir - button
        input_button = ttk.Button(self.process_frame, text="...", width=2, command=self.set_output_dir)
        input_button.grid(row=30, column=1, sticky=tk.W)

        # outputdir - textbox
        self.outputdir_text = tk.StringVar()
        outputdir_entry = ttk.Entry(self.process_frame, width=80, textvariable=self.outputdir_text)
        outputdir_entry.grid(row=30, column=1, columnspan=6, sticky=tk.W, padx=30)

        # ------ ROW 50 ------
        # ROW DETAILS
        # start row -label
        startrow_label = ttk.Label(self.process_frame, text='Start Row', font=('bold', 12))
        startrow_label.grid(row=50, column=0, sticky=tk.W, padx=5, pady=(20,0))

        # startrow - textbox
        self.startrow_text = tk.StringVar()
        startrow_entry = ttk.Entry(self.process_frame, textvariable=self.startrow_text)
        startrow_entry.grid(row=50, column=1, pady=(20,0))

        # endrow - label
        endrow_label = ttk.Label(self.process_frame, text='End Row', font=('bold', 12))
        endrow_label.grid(row=50, column=2, sticky=tk.W, pady=(20,0))

        # endrow - textbox
        self.endrow_text = tk.StringVar()
        endrow_entry = ttk.Entry(self.process_frame, textvariable=self.endrow_text)
        endrow_entry.grid(row=50, column=3, pady=(20,0))

        # currentrow - label
        currentrow_label = ttk.Label(self.process_frame, text='Current Row', font=('bold', 12))
        currentrow_label.grid(row=50, column=4, sticky=tk.W, pady=(20,0))

        # currentrow - textbox
        self.currentrow_text = tk.StringVar()
        currentrow_entry = ttk.Entry(self.process_frame, textvariable=self.currentrow_text)
        currentrow_entry.grid(row=50, column=5, pady=(20,0))

        # ----- SUB FRAME -----------
        input_fields_frame = ttk.Labelframe(self.process_frame, text="Input Fields")
        input_fields_frame.grid(row=100,column=0, columnspan=5
                                 , padx=5, pady=(20,0), sticky=tk.W)

        # ------ ROW 10 ------
        # street - label
        street_label = ttk.Label(input_fields_frame, text='Street', font=('bold', 12))
        street_label.grid(row=10,column=0, sticky=tk.W)

        # city - label
        city_label = ttk.Label(input_fields_frame, text='City', font=('bold', 12))
        city_label.grid(row=10, column=1, sticky=tk.W)

        # state - label
        state_label = ttk.Label(input_fields_frame, text='State', font=('bold', 12))
        state_label.grid(row=10, column=2, sticky=tk.W)

        # zipcode - label
        zipcode_label = ttk.Label(input_fields_frame, text='Zip Code', font=('bold', 12))
        zipcode_label.grid(row=10, column=3, sticky=tk.W)

        # ------ ROW 20 ------
        # include street - checkbox
        self.include_street = tk.IntVar()
        include_street_checkbox = ttk.Checkbutton(input_fields_frame, text='Include Street'
                                                  , variable=self.include_street, command=self.set_check_status)
        include_street_checkbox.grid(row=20, column=0, sticky=tk.W)

        # include city - checkbox
        self.include_city = tk.IntVar()
        include_city_checkbox = ttk.Checkbutton(input_fields_frame, text='Include City'
                                                  , variable=self.include_city, command=self.set_check_status)
        include_city_checkbox.grid(row=20, column=1, sticky=tk.W)

        # include state - checkbox
        self.include_state = tk.IntVar()
        include_state_checkbox = ttk.Checkbutton(input_fields_frame, text='Include State'
                                                  , variable=self.include_state, command=self.set_check_status)
        include_state_checkbox.grid(row=20, column=2, sticky=tk.W)

        # include zip - checkbox
        self.include_zip = tk.IntVar()
        include_zip_checkbox = ttk.Checkbutton(input_fields_frame, text='Include Zip'
                                                  , variable=self.include_zip, command=self.set_check_status)
        include_zip_checkbox.grid(row=20, column=3, sticky=tk.W)

        # ------ ROW 30 ------
        # street - textbox
        self.street_text = tk.StringVar()
        self.street_entry = tk.Entry(input_fields_frame, textvariable=self.street_text)
        self.street_entry.grid(row=30, column=0)

        # city - textbox
        self.city_text = tk.StringVar()
        self.city_entry = tk.Entry(input_fields_frame, textvariable=self.city_text)
        self.city_entry.grid(row=30, column=1)

        # state - textbox
        self.state_text = tk.StringVar()
        self.state_entry = tk.Entry(input_fields_frame, textvariable=self.state_text)
        self.state_entry.grid(row=30, column=2)

        # zipcode - textbox
        self.zipcode_text = tk.StringVar()
        self.zipcode_entry = tk.Entry(input_fields_frame, textvariable=self.zipcode_text)
        self.zipcode_entry.grid(row=30, column=3)

    def __drawwidgetsmessage(self):
        # ------ ROW 10 ------
        # progress message - label
        progress_label = tk.Label(self.message_frame, text='Progress Messages', font=('bold', 12))
        progress_label.grid(row=10, column=0, columnspan=3, sticky=tk.W, padx=(10, 0), pady=(10, 5))

        # result message - label
        result_label = tk.Label(self.message_frame, text='Result Messages', font=('bold', 12))
        result_label.grid(row=10, column=4, columnspan=2, sticky=tk.W, padx=(10, 0), pady=(10, 5))

        # currentrow - label
        currentrow2_label = ttk.Label(self.message_frame, text='Current Row', font=('bold', 12))
        currentrow2_label.grid(row=10, column=6, sticky=tk.W, padx=(10, 0), pady=(10, 5))

        # currentrow - textbox
        currentrow2_entry = ttk.Entry(self.message_frame, width=7, textvariable=self.currentrow_text)
        currentrow2_entry.grid(row=10, column=6, padx=(80, 0), pady=(10, 5))

        # ------ ROW 20 ------
        # progress message - listbox
        self.progress_list = tk.Listbox(self.message_frame, height=11, width=50, border=1)
        self.progress_list.grid(row=20, column=0, columnspan=3, rowspan=6, padx=(10, 0), pady=(5, 15))

        # progress message - scrollbar
        self.progress_scroll = tk.Scrollbar(self.message_frame)
        self.progress_scroll.grid(row=20, column=3, sticky=(tk.W, tk.N, tk.S))
        self.progress_list.configure(yscrollcommand=self.progress_scroll.set)
        self.progress_scroll.configure(command=self.progress_list.yview)

        # result message - listbox
        self.result_list = tk.Listbox(self.message_frame, height=11, width=50, border=1)
        self.result_list.grid(row=20, column=4, columnspan=3, rowspan=6, padx=(10, 0), pady=(5, 15))

        # result message - scrollbar
        self.result_scroll = tk.Scrollbar(self.message_frame)
        self.result_scroll.grid(row=20, column=7, sticky=(tk.W, tk.N, tk.S))
        self.result_list.configure(yscrollcommand=self.result_scroll.set)
        self.result_scroll.configure(command=self.result_list.yview)

    def __drawwidgetsgridentry(self):
        # ------ ROW 0  ------
        start_button = ttk.Button(self.grid_entry_frame, text="Start"
                                  , command=self.start_grid_processing)
        start_button.grid(row=0, column=0, padx=(5, 0), pady=(4, 0), sticky=tk.W)

        clear_button = ttk.Button(self.grid_entry_frame, text="Clear"
                                  , command=self.clear_grid_result)
        clear_button.grid(row=0, column=1, padx=(10, 0), pady=(4, 0), sticky=tk.W)

        # ----- SUB FRAME -----------
        input_fields_frame = ttk.Labelframe(self.grid_entry_frame, text="Input Fields")
        input_fields_frame.grid(row=1, column=0, columnspan=5
                                , padx=5, pady=(10, 0), sticky=tk.W)

        # ------ ROW 10 ------
        # street - label
        street_label = ttk.Label(input_fields_frame, text='Street', font=('bold', 12))
        street_label.grid(row=10, column=0, padx=(0, 5), sticky=tk.W)

        # city - label
        city_label = ttk.Label(input_fields_frame, text='City', font=('bold', 12))
        city_label.grid(row=10, column=1, padx=(10, 5), sticky=tk.W)

        # state - label
        state_label = ttk.Label(input_fields_frame, text='State', font=('bold', 12))
        state_label.grid(row=10, column=2, padx=(10, 5), sticky=tk.W)

        # zipcode - label
        zipcode_label = ttk.Label(input_fields_frame, text='Zip Code', font=('bold', 12))
        zipcode_label.grid(row=10, column=3, padx=(10, 5), sticky=tk.W)

        # ------ ROW 20 ------
        # include street - checkbox
        self.grid_include_street = tk.IntVar()
        include_street_checkbox = ttk.Checkbutton(input_fields_frame, text='Include Street'
                                                  , variable=self.grid_include_street)
        include_street_checkbox.grid(row=20, column=0, padx=(0, 5), sticky=tk.W)

        # include city - checkbox
        self.grid_include_city = tk.IntVar()
        include_city_checkbox = ttk.Checkbutton(input_fields_frame, text='Include City'
                                                , variable=self.grid_include_city)
        include_city_checkbox.grid(row=20, column=1, padx=(10, 5), sticky=tk.W)

        # include state - checkbox
        self.grid_include_state = tk.IntVar()
        include_state_checkbox = ttk.Checkbutton(input_fields_frame, text='Include State'
                                                 , variable=self.grid_include_state)
        include_state_checkbox.grid(row=20, column=2, padx=(10, 5), sticky=tk.W)

        # include zip - checkbox
        self.grid_include_zip = tk.IntVar()
        include_zip_checkbox = ttk.Checkbutton(input_fields_frame, text='Include Zip'
                                               , variable=self.grid_include_zip)
        include_zip_checkbox.grid(row=20, column=3, padx=(10, 5), sticky=tk.W)

        # ------ ROW 30 ------
        # street - textbox
        self.grid_street_text = tk.StringVar()
        street_entry = ttk.Entry(input_fields_frame, width=50, textvariable=self.grid_street_text)
        street_entry.grid(row=30, column=0, padx=(0, 5), pady=(2, 10))

        # city - textbox
        self.grid_city_text = tk.StringVar()
        city_entry = ttk.Entry(input_fields_frame, width=30, textvariable=self.grid_city_text)
        city_entry.grid(row=30, column=1, padx=(10, 5), pady=(2, 10))

        # state - textbox
        self.grid_state_text = tk.StringVar()
        state_entry = ttk.Entry(input_fields_frame, width=16, textvariable=self.grid_state_text)
        state_entry.grid(row=30, column=2, padx=(10, 5), pady=(2, 10))

        # zipcode - textbox
        self.grid_zipcode_text = tk.StringVar()
        self.zipcode_entry = ttk.Entry(input_fields_frame, width=15, textvariable=self.grid_zipcode_text)
        self.zipcode_entry.grid(row=30, column=3, padx=(10, 5), pady=(2, 10))

        # ----- SUB FRAME -----------
        results_frame = ttk.Labelframe(self.grid_entry_frame, text="Results -- Double Click to Expand")
        results_frame.grid(row=100, column=0, columnspan=5
                                , padx=5, pady=(10, 0), sticky=tk.W)
        results_frame.bind("<Double-Button-1>", self.__popup_results)

        # ------ ROW 10 ------
        # textbox - results
        self.grid_results_text = tk.Text(results_frame, width=90, height=6)
        self.grid_results_text.grid(row=10, column=0, padx=(0, 0), pady=(5, 5))
        self.grid_results_text.bind("<Double-Button-1>", self.__popup_results)

        result_scroll = ttk.Scrollbar(results_frame)
        result_scroll.grid(row=10, column=1, sticky=(tk.W, tk.N, tk.S))
        self.grid_results_text.configure(yscrollcommand=result_scroll.set)
        result_scroll.configure(command=self.grid_results_text.yview)

    def __popup_results(self, mouse_info=None):
        """Show pop up message box of the returned results"""
        popup = tk.Tk()
        popup.wm_title("Results")
        result = self.grid_results_text.get(1.0, tk.END)

        # if empty populate with friendly message
        if result is None or len(result) < 1:
            result = "No Results"

        # add the frame
        popup_frame = ttk.Frame(popup, padding="3 3 12 12")
        popup_frame.grid(column=0, row=0, sticky=(tk.N, tk.W, tk.E, tk.S))

        # add the listbox
        popup_list = tk.Text(popup_frame, height=30, width=120, wrap='none')
        popup_list.grid(column=0, row=0)

        popup_scroll = ttk.Scrollbar(popup_frame)
        popup_scroll.grid(row=0, column=1, sticky=(tk.W, tk.N, tk.S))
        popup_list.configure(yscrollcommand=popup_scroll.set)
        popup_scroll.configure(command=popup_list.yview)

        # add the text
        popup_list.insert(tk.END, result)

        # add ok button
        ok_button = ttk.Button(popup, text="Okay", command=popup.destroy)
        ok_button.grid(column=0, row=1)

        # wait for user to close window
        popup.mainloop()

    def updatebatchsize(self, val):
        batch_switch={'default': 50
                     , 'google': 25
                     , 'spectrum': 2}
        self.batchsize_text.set(batch_switch[val])

    def cancel_app(self):
        self.continue_processing = False
        # switch to the messages tab
        self.ttk_notebook.select(self.message_frame)

    def clear_progress_message(self):
        self.progress_list.delete(0, tk.END)
        self.result_list.delete(0, tk.END)

        # switch to the messages tab
        self.ttk_notebook.select(self.message_frame)

    def clear_grid_result(self):
        self.grid_results_text.delete(1.0, tk.END)

    def populatefields(self):
        try:
            """put default values into the fields if config file doesn't exist"""
            # api options
            self.apiurl_text.set(self.options.config['api_url'])
            self.apikey_text.set(self.options.config['api_key'])
            self.apimixed_text.set(self.options.config['api_mixed'])
            self.apicreate_text.set(self.options.config['api_create'])
            self.apiparser_text.set(self.options.config['api_parser'])
            self.batchsize_text.set(self.options.config['batch_size'])

            # processing info
            self.inputfile_text.set(self.options.config['input_file'])
            self.outputdir_text.set(self.options.config['output_dir'])
            self.startrow_text.set(self.options.config['start_row'])
            self.endrow_text.set(self.options.config['end_row'])
            self.currentrow_text.set(self.options.config['current_row'])

            # columns info
            self.street_text.set(self.options.config['street'])
            self.city_text.set(self.options.config['city'])
            self.state_text.set(self.options.config['state'])
            self.zipcode_text.set(self.options.config['zip'])
            self.include_street.set(self.options.config['include_street'])
            self.include_city.set(self.options.config['include_city'])
            self.include_state.set(self.options.config['include_state'])
            self.include_zip.set(self.options.config['include_zip'])

            # grid info
            self.grid_street_text.set(self.options.config['grid_street'])
            self.grid_city_text.set(self.options.config['grid_city'])
            self.grid_state_text.set(self.options.config['grid_state'])
            self.grid_zipcode_text.set(self.options.config['grid_zip'])
            self.grid_include_street.set(self.options.config['grid_include_street'])
            self.grid_include_city.set(self.options.config['grid_include_city'])
            self.grid_include_state.set(self.options.config['grid_include_state'])
            self.grid_include_zip.set(self.options.config['grid_include_zip'])

            self.output_field_list.delete(0, tk.END)
            outfield_list = ["locationFound"
                            , "standardizedInfo.passesVZValidation"
                            , "location.locationId"
                            , "location.baseLocationId"
                            , "location.iso3CountryCode"
                            , "location.addressLine1"
                            , "location.city"
                            , "location.stateProvince"
                            , "location.postalCodeBase"
                            , "location.postalCodeAddOn"
                            , "location.subLocType1"
                            , "location.subLocValue1"
                            , "standardizedInfo.standardizedAddress.formattedAddress"
                            , "standardizedInfo.geoCoordinate.latitude"]
            for item in outfield_list:
                self.output_field_list.insert(tk.END, item)
        except KeyError:
            # if the key doesn't exist in the dictionary
            # ignore and exit
            print("KeyError in Config File")
            pass

    def set_check_status(self):
        self.street_entry.config(state="normal") if self.include_street.get() == 1 else self.street_entry.config(state="disabled")
        self.city_entry.config(state="normal") if self.include_city.get() == 1 else self.city_entry.config(state="disabled")
        self.state_entry.config(state="normal") if self.include_state.get() == 1 else self.state_entry.config(state="disabled")
        self.zipcode_entry.config(state="normal") if self.include_zip.get() == 1 else self.zipcode_entry.config(state="disabled")

    def set_input_file(self):
        input_file = askopenfilename(filetypes=(("CSV files", "*.csv")
                                      , ("All files", "*.*"))
                                      , title='Open File'
                                     ) #, initialdir=str(Path.home()))
        self.inputfile_text.set(input_file)

    def set_output_dir(self):
        output_dir = askdirectory(title='Pick a folder'
                                  ) # , initialdir=str(Path.home()))
        self.outputdir_text.set(output_dir)

    def update_progress(self, msg):
        self.progress_list.insert(tk.END, msg)
        self.progress_list.yview(tk.END)

    def update_result(self, msg):
        self.result_list.insert(tk.END, msg)
        self.result_list.yview(tk.END)

    def update_grid_result(self, msg):
        self.grid_results_text.insert(tk.END, msg)
        self.grid_results_text.yview(tk.END)

    def update_row(self, msg):
        self.currentrow_text.set(msg)

    def populate_grid_df(self):
        grid_data = {'uid': [1]
                    , self.street_text.get(): [self.grid_street_text.get()]
                    , self.city_text.get(): [self.grid_city_text.get()]
                    , self.state_text.get(): [self.grid_state_text.get()]
                    , self.zipcode_text.get(): [self.grid_zipcode_text.get()]}

        self.options.config['grid_df'] = pd.DataFrame(data=grid_data)

    # ------------------------------------------------------------------------
    # APPLICATION GRID PROCESSING
    # ------------------------------------------------------------------------
    def start_grid_processing(self):
        if ((self.grid_street_text.get() == "" and self.grid_include_street == 0)
            or (self.grid_city_text.get() == "" and self.grid_include_city == 0)
            or (self.grid_state_text.get() == "" and self.grid_include_state == 0)
            or (self.grid_zipcode_text.get() == "" and self.grid_include_zip == 0)):
            messagebox.showerror("Required Fields", "Please populate all fields")
            return

        # update the config settings since they many have changed
        # since being initialized
        self.options.updateconfig()

        # create the data frame for processing
        self.populate_grid_df()

        # initiate separate thread for running the job
        api_task = th.Thread(target=__main__.start_grid_job, args=(self.options.config,))
        api_task.start()

    # ------------------------------------------------------------------------
    # APPLICATION BATCH PROCESSING
    # ------------------------------------------------------------------------
    def start_app(self):
        """start the main application """
        # check if the required fields have been populated
        if self.apikey_text.get() == "" \
                or self.inputfile_text.get() == "" \
                or self.outputdir_text.get() == "" \
                or self.startrow_text.get() == "" \
                or self.endrow_text.get() == "" \
                or self.street_text.get() == "" \
                or self.city_text.get() == "" \
                or self.state_text.get() == "" \
                or self.zipcode_text.get() == "":
            messagebox.showerror("Required Fields", "Please populate all fields")
            return

        # if initial flight check is ok, then continue with app
        self.continue_processing = True

        # update the config settings since they many have changed
        # since being initialized
        self.options.updateconfig()

        # switch to the messages tab
        self.ttk_notebook.select(self.message_frame)

        # initiate separate thread for running the job
        api_task = th.Thread(target=__main__.start_job, args=(self.options.config,))
        api_task.start()
