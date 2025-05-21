import numpy as np
import pandas as pd
import json                                 # json data from API


class userAddresses:
    def __init__(self, raw_df, args):
        self.raw_df = raw_df.copy()
        self.args = args
        self.num_columns = len(self.raw_df.columns)
        self.Addresses = dict()
        self.Addresses["mixedCase"] = self.args.usr_args['api_mixed']
        self.Addresses["generateIdIfNotExist"] = self.args.usr_args['api_create']
        self.Addresses["inputAddress"] = None
        if ((self.args.usr_args['api_parser'] == 'google') or (self.args.usr_args['api_parser'] == 'spectrum')):
            self.Addresses["addressParser"] = self.args.usr_args['api_parser']
        self.json_addresses = None

    def selectDataColumns(self):
        """rename the columns passed on user specifications"""
        self.raw_df.rename(inplace=True
                            , columns={self.args.usr_args['street']: "STREET__api"
                                    , self.args.usr_args['city']: "CITY__api"
                                    , self.args.usr_args['state']: "STATE__api"
                                    , self.args.usr_args['zip']: "ZIP__api"
                                    })

    def prepAddressess(self):
        """Prep the data frame for processing"""
        # replace NaN in Zip and Street
        self.raw_df['STREET__api'].fillna('BLANK', inplace=True)
        self.raw_df['CITY__api'].fillna('NO CITY', inplace=True)
        self.raw_df['STATE__api'].fillna('FL', inplace=True)
        self.raw_df['ZIP__api'].fillna(0, inplace=True)

        # add new column prepend five zeros
        self.raw_df.insert(loc=self.num_columns,
                           column="ZIP5",
                           value="00000" + self.raw_df['ZIP__api'].astype("str"),
                           allow_duplicates=True)

        # strip the right five characters
        self.raw_df['ZIP5'] = self.raw_df['ZIP5'].str[-5:]

    def populateAddresses(self):
        """Reformat the addresses into json format for API calls"""
        df_sub = self.raw_df[['uid', 'STREET__api', 'CITY__api', 'STATE__api', 'ZIP5']]

        if ((self.args.usr_args['api_parser'] == 'spectrum')
                or (self.args.usr_args['api_parser'] == 'google')):
            # google parser
            # based on include / exclude options from UI, include / exclude columns
            df_sub.insert(loc=5
                          , allow_duplicates=True
                          , column="inputAddress"
                          , value=(df_sub['STREET__api'].astype("str") + ', ' if self.args.usr_args['include_street'] else '')
                               + (df_sub['CITY__api'].astype("str") + ', ' if self.args.usr_args['include_city'] else '')
                               + (df_sub['STATE__api'].astype("str") + ' ' if self.args.usr_args['include_state'] else '')
                               + (df_sub['ZIP5'].astype("str") if self.args.usr_args['include_zip'] else '')
                          )
            # use a list for the addresses
            self.Addresses['inputAddress'] = df_sub['inputAddress'].to_list()

        else:
            # standard parser
            # use a dictionary for the addresses
            df_sub = df_sub.rename(columns={ "STREET__api": "addressLine1"
                                            , "CITY__api": "city"
                                            , "STATE__api": "stateProvince"
                                            , "ZIP5": "postalCode"
                                           })
            df_sub.insert(4, "country", "USA", True)
            self.Addresses['inputAddress'] = df_sub.to_dict(orient='records')

        # export to JSON for processing
        self.json_addresses = json.dumps(self.Addresses)
        self.Addresses = None
