#!/usr/bin/env bash
# Validate the contract locally with oasdiff.
#
# Usage:
#   scripts/validate-contract.sh [base.json] [revision.json]
#
# Defaults:
#   base     = git show <base-ref>:contracts/openapi.json
#              (env BASE_REF, default "trunk")
#   revision = contracts/openapi.json
#
# Requires Docker. Exits non-zero on breaking changes.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_REF="${BASE_REF:-trunk}"
REVISION="${2:-$ROOT/contracts/openapi.json}"

if [[ $# -ge 1 ]]; then
  BASE="$1"
else
  BASE="$(mktemp)"
  if git -C "$ROOT" show "$BASE_REF:contracts/openapi.json" > "$BASE" 2>/dev/null; then
    echo "Base: $BASE_REF:contracts/openapi.json"
  else
    echo "No base contract at '$BASE_REF:contracts/openapi.json'; nothing to compare." >&2
    exit 0
  fi
fi

if [[ ! -f "$REVISION" ]]; then
  echo "Revision not found: $REVISION" >&2
  exit 1
fi

docker run --rm \
  -v "$(dirname "$BASE"):/base:ro" \
  -v "$(dirname "$REVISION"):/revision:ro" \
  tufin/oasdiff breaking "/base/$(basename "$BASE")" "/revision/$(basename "$REVISION")" --fail-on ERR
