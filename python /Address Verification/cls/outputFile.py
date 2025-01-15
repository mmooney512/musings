import numpy as np
import pandas as pd
from pandas.io.json import json_normalize   # moving json data in/out data frame
from pathlib import Path                    # used for local files

class outputFile:
    def __init__(self, output_path: str, file_len=0):
        self.csv_output_path = Path(output_path)
        self.retry_attempts = 0
        self.success = False
        self.suffix = "_addresses.csv"
        self.output_columns = None
        self.__output_columns()
        self.__set_prefix(file_len)

    def __output_columns(self):
        self.output_columns = list(['locationFound'
                                    , 'standardizedInfo.passesVZValidation'
                                    , 'location.locationId'
                                    , 'location.baseLocationId'
                                    , 'location.iso3CountryCode'
                                    , 'location.addressLine1'
                                    , 'location.city'
                                    , 'location.stateProvince'
                                    , 'location.postalCodeBase'
                                    , 'location.postalCodeAddOn'
                                    , 'location.subLocType1'
                                    , 'location.subLocValue1'
                                    , 'standardizedInfo.standardizedAddress.formattedAddress'
                                    , 'standardizedInfo.geoCoordinate.latitude'
                                    , 'standardizedInfo.geoCoordinate.longitude'
                                    , 'location.telcoInfo.inRegion'
                                    , 'location.telcoInfo.lata'
                                    , 'location.telcoInfo.wcName'
                                    , 'location.telcoInfo.wcLecCode'
                                    , 'location.telcoInfo.rcName'
                                    , 'location.telcoInfo.rcState'
                                    ])

    def __set_prefix(self, file_len):
        """Add leading zeroes for saving the file"""
        if file_len <= 0:
            print(f"File Length: {file_len}")
            raise OSError("output_file::set_prefix Invalid file length")
        self.output_prefix = len(str(file_len))

    def parse_file(self, current_index, json_data, df_curr, uid: list):
        try:
            if json_data["returnCode"] != 0:
                print(f"Error Processing: {current_index} {json_data['returnMessage']}")
                self.success = False
            else:
                df_shell = pd.DataFrame(data=None, index=None, columns=self.output_columns)

                r_val = json_data["responses"]
                df_v = json_normalize(r_val)

                # list intersection doesn't keep the order
                # col_list = list(set(self_output_columns).intersection(df_v.columns)

                # set intersection keeping the order
                col_list = sorted(set(self.output_columns) & set(df_v.columns)
                                  , key=self.output_columns.index)

                # create the filtered by columns dataframe
                df_output = df_shell.append(df_v[col_list].copy(),sort=False)

                # add uid from df_raw
                df_output['uid'] = uid

                # merge the data frames
                df_combined = pd.merge(df_curr, df_output, on='uid')

                # pad the output file name with leading zeroes
                csv_out_name = str(current_index).zfill(self.output_prefix) + self.suffix

                # output the file to csv
                df_combined.to_csv(self.csv_output_path / csv_out_name)
                self.retry_attempts = 0
                self.success = True

        # need to catch all exception types since we don't know
        # all the codes that the api PB call will throw back
        except Exception as e:
            print(f"Error Processing: {current_index} outputfile:: {e}")
            self.retry_attempts = self.retry_attempts + 1
            pass
