#!/usr/bin/env bash
# Deprecated: use `./dev`. Kept for the old one-command entry point.
exec "$(dirname "${BASH_SOURCE[0]}")/dev" "$@"
