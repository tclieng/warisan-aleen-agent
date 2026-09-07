import urllib.request, urllib.parse, json

WARISAN_PAGE_TOKEN = "EAAPDQzuaQk8BSTqk7TN1w9zXFlPwLaKKJmNN9mA6oTDtlIpPaPVHLxGA1Vbf04ZCDlByB8DobfZAhMQKeXyUruzuWaJbGHomAsUoE9YCyOEFCZBPycZCFsVn4aPHogMlGGXJCLwVuCbfZANZBrw3QXWW23RpDbOB2lASeRKsDme77wIvOKBchbxmzFoGUgaWlz9faDxZBvAuxMugEYchsvWn7Q3tLDtstLKMOnz8bi1"
PAGE_ID = "1369264899593189"

print("=== POST to Warisan Aleen page (using page's own token) ===", flush=True)
url = f"https://graph.facebook.com/v26.0/{PAGE_ID}/feed"
data = urllib.parse.urlencode({
    "message": "🤖 First auto-post!\n\nSalam semua! Warisan Aleen AI Agent is now live.\n\nKampong-style Malaysian cuisine, coming soon! 🍛",
    "access_token": WARISAN_PAGE_TOKEN
}).encode()
try:
    r = urllib.request.urlopen(urllib.request.Request(url, data=data), timeout=15)
    d = json.loads(r.read())
    print("SUCCESS:", json.dumps(d, indent=2), flush=True)
except Exception as e:
    if hasattr(e, 'read'):
        body = e.read().decode()
        print("ERROR:", body, flush=True)
    else:
        print("ERROR:", e, flush=True)

print("\n=== Debug Warisan Aleen page token ===", flush=True)
debug_url = f"https://graph.facebook.com/debug_token?input_token={WARISAN_PAGE_TOKEN}&access_token={WARISAN_PAGE_TOKEN}"
try:
    r2 = urllib.request.urlopen(debug_url, timeout=15)
    d2 = json.loads(r2.read())
    print(json.dumps(d2, indent=2), flush=True)
except Exception as e:
    if hasattr(e, 'read'):
        print("DEBUG ERROR:", e.read().decode(), flush=True)
    else:
        print("DEBUG ERROR:", e, flush=True)
