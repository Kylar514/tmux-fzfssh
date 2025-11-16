#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pwsh -NoProfile -File "$CURRENT_DIR/parsers/parse_categories.ps1"
