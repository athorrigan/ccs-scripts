import requests
import json
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

#Change Me
host = "[IP Address]"
auth = "Basic [Authorization key]"

# Code
url = "https://" + host + "/cloudcenter-ccm-backend/api/v1/user/keys"

headers = {
    'Accept': "application/json",
    'Authorization': auth,
    'User-Agent': "Python",
    'Cache-Control': "no-cache",
    'accept-encoding': "gzip, deflate",
    'Connection': "keep-alive",
    'cache-control': "no-cache"
    }

response = requests.request("GET", url, headers=headers, verify=False)

print(json.loads(response.text)['sshKeys'][0]['key'])
