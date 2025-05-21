import requests                             # used for web requests / API calls

class apiHandler:
    """class for working with api"""
    def __init__(self, api_url, api_key):
        # self.api_url = "https://oa.verizon.com:9004/locusaddressapi/api/address/getByAddress"
        # self.api_url = "https://oa-uat.ebiz.verizon.com/locusaddressapi/api/address/getByAddress"
        self.api_url = api_url
        self.api_key = api_key
        self.json_response = None

    def sendRequest(self, request_object):
        api_response = requests.post(self.api_url
                                     , params={'apikey': self.api_key}
                                     , data=request_object
                                     )
        self.json_response = api_response.json()

    def validateResponse(self):
        pass
