import requests

# Fresh stealth founder leads — the deal-flow query.
resp = requests.get(
    "https://www.startuphub.ai/api/v1/startups",
    params={
        "stealth": "true",
        "domain_tld": "ai,io",
        "has_known_emails": "true",
        "sort": "founded_date.desc",
        "limit": 20,
    },
    headers={"Authorization": "Bearer sk_live_..."},
)

data = resp.json()
