#!/usr/bin/env bash
# Manually trigger the Contract Sync workflow in dmoney_platform.
#
# Usage:
#   scripts/dispatch-contract-sync.sh [back-ref]
#
# Defaults to "trunk". Requires the GitHub CLI (gh) authenticated with access
# to DavidUpegui/dmoney_platform.

set -euo pipefail

REF="${1:-trunk}"
REPO="DavidUpegui/dmoney_platform"

gh workflow run contract-sync.yml \
  --repo "$REPO" \
  -f ref="$REF"

echo "Dispatched contract-sync against dmoney_back@$REF"
