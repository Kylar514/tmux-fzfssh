#!/usr/bin/env bash

SSH_CONFIG="${SSH_CONFIG:-$HOME/.ssh/config}"

# -------------------------
# Return all hosts for fzf
# -------------------------
get_all_hosts() {
    awk '
    BEGIN { block=""; host="" }
    {
        if ($1 == "Host") {
            if (block != "" && host != "") {
                # Save paragraph to file for preview
                print host "\t" block > "/tmp/fzfssh_preview_" host
            }
            host=$2
            block=$0 "\n"
        } else {
            block=block $0 "\n"
        }
    }
    END {
        if (block != "" && host != "") {
            print host "\t" block > "/tmp/fzfssh_preview_" host
        }
    }
    ' "$SSH_CONFIG"

    # Output only host names for fzf
    awk -F'\t' '{print $1}' /tmp/fzfssh_preview_*
}

# -------------------------
# Preview function for fzf
# Given host name, prints the paragraph
# -------------------------
preview_host() {
    local host="$1"
    cat "/tmp/fzfssh_preview_$host" 2>/dev/null
}

# -------------------------
# Cleanup preview temp files
# -------------------------
cleanup_previews() {
    rm -f /tmp/fzfssh_preview_*
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_all_hosts_for_fzf | fzf --with-nth=1 --delimiter=$'\t' --preview 'parser_test.sh preview_host {}' --prompt "Select host: "
fi
