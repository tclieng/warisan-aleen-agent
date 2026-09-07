import urllib.request, urllib.parse, json

# Current Explorer token (trim any whitespace)
TOKEN = "EAAPDQzuaQk8BSVTG9QVqKqMegImoSdcq0GEcCZBiugcNdcBx1ITDjZBkO8b0Q1MdUWaHy3sj0ZCpcsU9WXegz1L0UaAEJ6uHya6kqHZArTvxGZBdZCNKswcsibNknrDEHl87d27MziHp8ybkIuK6U8CTZBYBeCERZAsR1BZCXGs4eT6xLQd0ZBPbMVGSqPA382gaqk9XYaYPjIjf1VurzyfZCbMgtTZBGjsjsIm7tngZD"
IG_ID = "17841425967343775"

print("=== Check IG Account ===")
params = urllib.parse.urlencode({"fields": "id,username,name,followers_count,media_count", "access_token": TOKEN})
url = f"https://graph.facebook.com/v26.0/{IG_ID}?{params}"
try:
    r = urllib.request.urlopen(url, timeout=15)
    print(json.dumps(json.loads(r.read()), indent=2))
except Exception as e:
    if hasattr(e, 'read'):
        print("IG error:", e.read().decode()[:500])
    else:
        print("ERR:", str(e)[:300])

print("\n=== Get CL Tan's Facebook profile ===")
params2 = urllib.parse.urlencode({"fields": "id,name,email,accounts", "access_token": TOKEN})
url2 = f"https://graph.facebook.com/v26.0/me?{params2}"
try:
    r2 = urllib.request.urlopen(url2, timeout=15)
    d2 = json.loads(r2.read())
    print(json.dumps(d2, indent=2))
    # Save accounts for reference
    if 'accounts' in d2:
        with open("C:/Users/MK-User/.qclaw/workspace/warisan-agent/cl_accounts.json", "w") as f:
            json.dump(d2['accounts'], f, indent=2)
except Exception as e:
    if hasattr(e, 'read'):
        print("Me error:", e.read().decode()[:500])
    else:
        print("ERR:", str(e)[:300])

print("\n=== Get Warisan Aleen Page token ===")
PAGE_ID = "1369264899593189"
params3 = urllib.parse.urlencode({"fields": "id,name,access_token", "access_token": TOKEN})
url3 = f"https://graph.facebook.com/v26.0/{PAGE_ID}?{params3}"
try:
    r3 = urllib.request.urlopen(url3, timeout=15)
    d3 = json.loads(r3.read())
    print(json.dumps(d3, indent=2))
    pt = d3.get('access_token', '')
    if pt:
        with open("C:/Users/MK-User/.qclaw/workspace/warisan-agent/warisan_page_token.txt", "w") as f:
            f.write(pt)
        print("Page token saved:", pt[:50] + "...")
        
        # Try posting with page token
        print("\n=== Try POST with page token ===")
        post_data = urllib.parse.urlencode({
            "message": "🤖 Auto test from Warisan Aleen Agent.",
            "access_token": pt
        }).encode()
        post_url = f"https://graph.facebook.com/v26.0/{PAGE_ID}/feed"
        try:
            rp = urllib.request.urlopen(urllib.request.Request(post_url, data=post_data), timeout=15)
            dp = json.loads(rp.read())
            print("POST SUCCESS:", dp)
        except Exception as e2:
            if hasattr(e2, 'read'):
                print("POST error:", e2.read().decode()[:500])
            else:
                print("POST ERR:", str(e2)[:300])
except Exception as e:
    if hasattr(e, 'read'):
        print("Page token error:", e.read().decode()[:500])
    else:
        print("ERR:", str(e)[:300])
