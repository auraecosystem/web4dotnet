curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
  -H 'Content-Type: application/json' \
  -H "x-goog-api-key: "" \
  -X POST \
  -d '{
    "model": "gemini-3.5-flash",
    "input": "Explain how AI works in a few words"
  }'
