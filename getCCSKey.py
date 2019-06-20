import requests
import json
import urllib3
import base64

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

#Change Me
host = "192.133.157.180:32077"
auth = b'32768:d3460c17-47a7-4a99-b693-e9c7ee6a41ae'

# Code
auth = base64.b64encode(auth).decode('utf-8')
url = "https://" + host + "/cloudcenter-ccm-backend/api/v1/user/keys"

headers = {
    'Accept': "application/json",
    'Authorization': "Basic %s" % auth,
    'User-Agent': "Python",
    'Cache-Control': "no-cache",
    'accept-encoding': "gzip, deflate",
    'Connection': "keep-alive",
    'cache-control': "no-cache"
    }

response = requests.request("GET", url, headers=headers, verify=False)

print(json.loads(response.text)['sshKeys'][0]['key'])
