#!/usr/bin/env bash

set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:4000}"
SOURCE="${SOURCE:-myanimelistanime}"
QUERY="${QUERY:-rezero}"
SPOILER_LEVEL="${SPOILER_LEVEL:-standard}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "[sayless] python3 is required for smoke_api.sh"
  exit 1
fi

if ! curl -fsS --max-time 3 "${API_BASE_URL}/" >/dev/null 2>&1; then
  echo "[sayless] Backend is not reachable at ${API_BASE_URL}."
  echo "[sayless] Start the API first, then rerun ./scripts/smoke_api.sh."
  exit 1
fi

echo "[sayless] Searching '$QUERY' on source '$SOURCE'..."
SEARCH_RESPONSE="$(curl -fsS "${API_BASE_URL}/api/v1/search?source=${SOURCE}&query=${QUERY}")"

MEDIA_ID="$(
  printf '%s' "$SEARCH_RESPONSE" | python3 -c '
import json, sys
data = json.load(sys.stdin)["data"]["results"]
if not data:
    raise SystemExit(1)
print(data[0]["id"])
'
)"

echo "[sayless] Using media id: ${MEDIA_ID}"
TARGETS_RESPONSE="$(curl -fsS "${API_BASE_URL}/api/v1/media/${SOURCE}/${MEDIA_ID}/targets")"

TARGET_INFO="$(
  printf '%s' "$TARGETS_RESPONSE" | python3 -c '
import json, sys
data = json.load(sys.stdin)["data"]["targets"]
if not data:
    raise SystemExit(1)
first = data[0]
print(first["type"])
print(first["id"])
'
)"

TARGET_TYPE="$(printf '%s' "$TARGET_INFO" | sed -n '1p')"
TARGET_ID="$(printf '%s' "$TARGET_INFO" | sed -n '2p')"

echo "[sayless] Using target ${TARGET_TYPE}:${TARGET_ID}"
echo "[sayless] Requesting summary..."

curl -fsS \
  -X POST "${API_BASE_URL}/api/v1/summarize" \
  -H "Content-Type: application/json" \
  -d "{
    \"source\": \"${SOURCE}\",
    \"media_id\": \"${MEDIA_ID}\",
    \"target_type\": \"${TARGET_TYPE}\",
    \"target_id\": \"${TARGET_ID}\",
    \"spoiler_level\": \"${SPOILER_LEVEL}\"
  }"

echo
