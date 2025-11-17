#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CATEGORY="${1:-}"

if [[ -z "$CATEGORY" ]]; then
    pwsh -NoProfile -File "$CURRENT_DIR/parser.ps1"
else
    pwsh -NoProfile -File "$CURRENT_DIR/parser.ps1" -Filter "$CATEGORY"
fi
