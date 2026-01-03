import requests
import json
url = "https://skaagpay-backend.vercel.app/api/recharge/plans/?limit=1"
try:
    resp = requests.get(url)
    data = resp.json()
    if isinstance(data, list):
        print("TYPE: LIST")
        print(f"COUNT: {len(data)}")
    elif isinstance(data, dict):
        print("TYPE: DICT")
        print(f"KEYS: {list(data.keys())}")
        if 'results' in data:
            print(f"RESULTS COUNT: {len(data['results'])}")
except Exception as e:
    print(f"ERROR: {e}")
