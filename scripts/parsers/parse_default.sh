#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# parse_default.sh
# Parse ~/.ssh/config and output list of hosts with optional comment and proxy
# -----------------------------------------------------------------------------

SSH_CONFIG="$HOME/.ssh/config"

awk '
BEGIN { RS=""; FS="\n" }
{
    host = ""; comment = ""; proxy = "-"
    for (i = 1; i <= NF; i++) {
        # Capture first comment line
        if ($i ~ /^[[:space:]]*# / && comment == "") {
            comment = $i
            sub(/^[[:space:]]*# /, "", comment)
        }
        # Capture Host
        if ($i ~ /^[[:space:]]*Host /) {
            split($i, a, " ")
            host = a[2]
        }
        # Capture ProxyJump if exists
        if ($i ~ /^[[:space:]]*ProxyJump /) {
            split($i, a, " ")
            proxy = a[2]
        }
    }
    if (host != "") {
        printf "%-20s\t%-40s\t%-20s\n", host, comment, proxy
    }
}
' "$SSH_CONFIG"
