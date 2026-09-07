import urllib.request, json, sys

USER_TOKEN = "EAAPDQzuaQk8BSZAM92ZB2OwX6CxVpxsh9SuB2jFzLr8pHfMM6GptN6dM3sZBkM8aPEiLsZBBCEYsBj8LXjmlfmARzewXund50NkCx1grZCHh9I6yVv1wf6PAuX3LErWBCrAkpPXugviZCUFJgmx09tyDqPtUq1EYZAzznrEnPp0aJNh7wgRFrkczZBcAITUrLXC4sGFC6FH4dYVOLZBK7LI4gtssRtnqZCQpo7nAZDZD"

print("=== Get Page Token ===", flush=True)
url = f"https://graph.facebook.com/v26.0/me/accounts?access_token={USER_TOKEN}"
try:
    r = urllib.request.urlopen(url, timeout=15)
    d = json.loads(r.read())
    print(json.dumps(d, indent=2), flush=True)
    with open("C:/Users/MK-User/.qclaw/workspace/warisan-agent/pages_response.json", "w") as f:
        json.dump(d, f, indent=2)
    print("SAVED", flush=True)
except Exception as e:
    print(f"ERROR: {e}", flush=True)
    import traceback; traceback.print_exc()
