#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Load prebuilt arguments from tmux
eval $(tmux show-option -gqv @fzfssh-_built-args)

# 2. Load your host list (or any input)
# HOSTS_FILE="$CURRENT_DIR/hosts.txt"
# if [[ ! -f "$HOSTS_FILE" ]]; then
#     echo "No hosts.txt found at $HOSTS_FILE"
#     exit 1
# fi
#
# INPUT=$(cat "$HOSTS_FILE")

# 3. Run fzf using the args array
#    (args comes from the tmux option)
SELECTED=$("$CURRENT_DIR/list_default.sh" | fzf "${args[@]}")

# 4. Handle the selection
if [[ -n "$SELECTED" ]]; then
    echo "You selected: $SELECTED"
    # Example action: SSH to the host
    # ssh "$SELECTED"
fi
