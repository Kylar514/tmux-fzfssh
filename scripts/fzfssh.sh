#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

eval $(tmux show-option -gqv @fzfssh-_built-args)

run_fzf() {
    local list_script="$1"
    shift
    local script_args=("$@")

    LIST=$("$CURRENT_DIR/$list_script" "${script_args[@]}" | fzf "${args[@]}")

    if [[ -n "$LIST" ]]; then
        line="${LIST%"${LIST##*[![:space:]]}"}"

        TYPE="${line##* }"
        SELECTED="${line%% *}"

        case "$TYPE" in
            Host)
                echo "Selected: $SELECTED"
                echo "TYPE: $TYPE"
                ;;
            Action)
                echo "Performing action: $SELECTED"
                return 0
                ;;
            Category)
                # echo "Reloading FZF with default list..."
                # echo "Selected: $SELECTED"

                run_fzf "list_hosts.sh" "$SELECTED"
                ;;
            *)
                echo "Unknown TYPE: $TYPE"
                ;;
        esac
    fi
}

run_fzf "list_hosts.sh"
