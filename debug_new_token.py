import urllib.request, json

NEW_TOKEN = "EAAPDQzuaQk8BSYOFRZAwckJwTuHRGA1zqXlYEnYmzMBHcJGpQK15vWUX7z4a4MRnrYKMuj4ZAXx1XofPgChFrwysNDXsMenbnttKDujALtF8GgSPxPLDoarezlvMSFcmnS1jiFoGIi7SinMJ3sb4ZAVejPm0IibOmk2ucKIQoNgp7x9Qv4OZCaH4K8USoEMfLGgS6q5mXNuoGUGtRyT9LpJ5ZCWzsRFp0UgZDZD"
APP_TOKEN = "EAACEdEose0cBACZBZCJZB2wZC0ZBdZCKZBZCJZBZBZCJZBZBZCJZBZBZCJBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZBZB"

BASE = "https://graph.facebook.com/v26.0"

print("=== DEBUG NEW TOKEN ===")
url = f"https://graph.facebook.com/debug_token?input_token={NEW_TOKEN}&access_token={NEW_TOKEN}"
try:
    r = urllib.request.urlopen(url, timeout=15)
    d = json.loads(r.read())
    print(json.dumps(d, indent=2))
    scopes = d['data'].get('scopes', [])
    print("SCOPES:", scopes)
    # Save for later
    with open("C:/Users/MK-User/.qclaw/workspace/warisan-agent/new_token_scopes.txt", "w") as f:
        f.write(str(scopes))
except Exception as e:
    if hasattr(e, 'read'):
        print("ERR:", e.read().decode())
    else:
        print("ERR:", e)

print("\n=== WHO AM I ===")
url2 = f"{BASE}/me?access_token={NEW_TOKEN}"
try:
    r2 = urllib.request.urlopen(url2, timeout=15)
    print(json.dumps(json.loads(r2.read()), indent=2))
except Exception as e:
    if hasattr(e, 'read'):
        print("ERR:", e.read().decode())
    else:
        print("ERR:", e)

print("\n=== me/accounts ===")
url3 = f"{BASE}/me/accounts?access_token={NEW_TOKEN}"
try:
    r3 = urllib.request.urlopen(url3, timeout=15)
    d3 = json.loads(r3.read())
    print(json.dumps(d3, indent=2))
    with open("C:/Users/MK-User/.qclaw/workspace/warisan-agent/new_accounts.json", "w") as f:
        json.dump(d3, f, indent=2)
except Exception as e:
    if hasattr(e, 'read'):
        print("ERR:", e.read().decode())
    else:
        print("ERR:", e)
