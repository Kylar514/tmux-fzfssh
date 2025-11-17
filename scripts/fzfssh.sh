#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Load prebuilt arguments from tmux
eval $(tmux show-option -gqv @fzfssh-_built-args)

# 2. Handle the selection
run_fzf() {
    local list_script="$1"

    LIST=$("$CURRENT_DIR/$list_script" | fzf "${args[@]}")

    if [[ -n "$LIST" ]]; then
        line="${LIST%"${LIST##*[![:space:]]}"}"

        TYPE="${line##* }"
        SELECTED="${line%% *}"

        # echo "Selected: $DISPLAY"
        # echo "TYPE: $TYPE"

        case "$TYPE" in
            Host)
                # HOSTNAME="${DISPLAY%% *}"
                # echo "SSH to host: $HOSTNAME"
                # return 0
                echo "Selected: $SELECTED"
                echo "TYPE: $TYPE"
                ;;
            Action)
                echo "Performing action: $SELECTED"
                return 0
                ;;
            Category)
                echo "Reloading FZF with default list..."
                echo "Selected: $SELECTED"
                # Recursive call to run_fzf with a different list
                run_fzf "list_default.sh"
                ;;
            *)
                echo "Unknown TYPE: $TYPE"
                ;;
        esac
    fi
}

# Initial FZF run with the default list
run_fzf "list_category.sh"
