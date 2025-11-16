#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Output the parsed list
cat "$CURRENT_DIR/hosts.txt"
