#!/usr/bin/env zsh
# Google Generative Language API client script
# Requires: GOOGLE_API_KEY environment variable or .env file

set -e  # Exit on error

# Load environment variables from .env file if it exists
if [[ -f ".env" ]]; then
  source .env
fi

# Validate API key is set
if [[ -z "${GOOGLE_API_KEY}" ]]; then
  echo "Error: GOOGLE_API_KEY environment variable not set"
  echo "Set it in .env file or export it: export GOOGLE_API_KEY=your_key_here"
  exit 1
fi

# API configuration
API_URL="https://generativelanguage.googleapis.com/v1beta/interactions"
MODEL="${1:-gemini-3.5-flash}"
INPUT="${2:-Explain how AI works in a few words}"

# Build JSON payload
PAYLOAD=$(cat <<EOF
{
  "model": "${MODEL}",
  "input": "${INPUT}"
}
EOF
)

echo "📡 Calling Google Generative Language API..."
echo "Model: ${MODEL}"
echo "Input: ${INPUT}"
echo ""

# Make API request with error handling
response=$(curl -s -w "\n%{http_code}" \
  "${API_URL}" \
  -H 'Content-Type: application/json' \
  -H "x-goog-api-key: ${GOOGLE_API_KEY}" \
  -X POST \
  -d "${PAYLOAD}")

# Parse response and HTTP status
http_code=$(echo "${response}" | tail -n 1)
body=$(echo "${response}" | head -n -1)

# Check HTTP status
if [[ "${http_code}" != "200" ]]; then
  echo "❌ API Error (HTTP ${http_code}):"
  echo "${body}" | jq '.' 2>/dev/null || echo "${body}"
  exit 1
fi

# Pretty-print successful response
echo "✅ Success:"
echo "${body}" | jq '.'
