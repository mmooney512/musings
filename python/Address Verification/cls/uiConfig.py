import json                     # read and write config file in json format
import os
import os.path                  # check if files exist
from pathlib import Path        # used for local files
import weakref                  # aid with gc
from tkinter import messagebox  # pop up messages
from tkinter.filedialog import askopenfilename, asksaveasfilename

class uiConfig:
    def __init__(self, ui_parent):
        # use weakref for proper gc
        self.ui_parent = ui_parent  # weakref.ref(ui_parent)

        # config used to hold run time parameters
        self.config = {}

        # current working directory
        self.cwd = os.getcwd()

        # load the default values into the configuration
        self.__default_values()

    def __check_config_file(self,filename=None):
        """check if the config file is valid"""
        # TODO write f(x) to scan and make sure config file is valid
        if filename is None:
            pass

    def __default_values(self):
        self.config = {'api_url'            : "https://oa.verizon.com:9004/locusaddressapi/api/address/getByAddress"
                       , 'api_key'          : "Enter API Key"
                       , 'api_create'       : "false"
                       , 'api_mixed'        : "false"
                       , 'api_parser'       : "default"
                       , 'batch_size'       : "50"
                       , 'input_file'       : "Click button to select input .csv file"
                       , 'output_dir'       : "Click button to select output directory"
                       , 'start_row'        : "0"
                       , 'end_row'          : "999999"
                       , 'current_row'      : "0"
                       , 'street'           : "STREET"
                       , 'include_street'   : 1
                       , 'city'             : "CITY"
                       , 'include_city'     : 1
                       , 'state'            : "STATE"
                       , 'include_state'    : 1
                       , 'zip'              : "ZIP"
                       , 'include_zip'      : 1
                       # grid entries
                       , 'grid_street'      : ''
                       , 'grid_city'        : ''
                       , 'grid_state'       : ''
                       , 'grid_zip'         : ''
                       , 'grid_include_street' : 1
                       , 'grid_include_city'   : 1
                       , 'grid_include_state'  : 1
                       , 'grid_include_zip'    : 1
                    }

    # ---- File processing functions -------------
    def getconfigfile(self):
        """get config file from local directory"""
        input_file = askopenfilename(filetypes=(("Text files", "*.txt")
                                      , ("All files", "*.*"))
                                      , title='Open File'
                                      )
        self.loadconfigfile(input_file)

    def loadconfigfile(self, filename=None, initial=False):
        """load the config file from local directory"""
        # if the initial state will load in the default values
        if initial:
            self.ui_parent.populatefields()

        # if filename isn't passed try to load default config
        if filename is None:
            filename = Path(self.cwd + "/" + "locus.config")

        # check if the supplied file name is valid
        if os.path.isfile(filename):
            with open(filename, 'r') as file_handle:
                temp_file = file_handle.read()
                file_handle.close()

            # check the size of the config file and load into the dictionary
            if len(temp_file) > 1 and len(temp_file) < 5000:
                temp_dict = json.loads(temp_file)

                # if correct amount of items in dict
                # TODO __check_config_file
                if len(temp_dict) >= 15 and len(temp_dict) <= 50:
                    self.config = temp_dict
                    self.ui_parent.populatefields()
                    self.ui_parent.set_check_status()
                    self.ui_parent.updatebatchsize(self.ui_parent.apiparser_text.get())

    def saveconfigfile(self, filename=None):
        """save a configuration file locally"""
        # re-populate the config dictionary
        self.updateconfig()

        # save out the config file
        if len(self.config) > 0:
            if filename is None:
                # get the file name
                filename = asksaveasfilename(defaultextension=".txt"
                                            , filetypes=(("text file", "*.txt"), ("All Files", "*.*"))
                                            )
                with open(filename, 'w+') as file_handle:
                    file_handle.write(json.dumps(self.config))
                    file_handle.close()

            else:
                messagebox.showerror("Invalid Configuration"
                                     , "Configuration file couldn't be created")
                pass

    def updateconfig(self):
        """update the config with values from ui"""
        # api info
        self.config['api_url'] = self.ui_parent.apiurl_text.get()
        self.config['api_key'] = self.ui_parent.apikey_text.get()
        self.config['api_mixed'] = self.ui_parent.apimixed_text.get()
        self.config['api_create'] = self.ui_parent.apicreate_text.get()
        self.config['api_parser'] = self.ui_parent.apiparser_text.get()
        self.config['batch_size'] = self.ui_parent.batchsize_text.get()

        # processing
        self.config['input_file'] = self.ui_parent.inputfile_text.get()
        self.config['output_dir'] = self.ui_parent.outputdir_text.get()
        self.config['start_row'] = self.ui_parent.startrow_text.get()
        self.config['end_row'] = self.ui_parent.endrow_text.get()
        self.config['current_row'] = self.ui_parent.currentrow_text.get()

        # columns info
        self.config['street'] = self.ui_parent.street_text.get()
        self.config['city'] = self.ui_parent.city_text.get()
        self.config['state'] = self.ui_parent.state_text.get()
        self.config['zip'] = self.ui_parent.zipcode_text.get()
        self.config['include_street'] = self.ui_parent.include_street.get()
        self.config['include_city'] = self.ui_parent.include_city.get()
        self.config['include_state'] = self.ui_parent.include_state.get()
        self.config['include_zip'] = self.ui_parent.include_zip.get()

        # grid info
        self.config['grid_street'] = self.ui_parent.grid_street_text.get()
        self.config['grid_city'] = self.ui_parent.grid_city_text.get()
        self.config['grid_state'] = self.ui_parent.grid_state_text.get()
        self.config['grid_zip'] = self.ui_parent.grid_zipcode_text.get()
        self.config['grid_include_street'] = self.ui_parent.grid_include_street.get()
        self.config['grid_include_city'] = self.ui_parent.grid_include_city.get()
        self.config['grid_include_state'] = self.ui_parent.grid_include_state.get()
        self.config['grid_include_zip'] = self.ui_parent.grid_include_zip.get()
