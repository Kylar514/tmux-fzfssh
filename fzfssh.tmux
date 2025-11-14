#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

# source "$SCRIPTS_DIR/parser.sh"
# source "$SCRIPTS_DIR/actions.sh"

tmux_option_or_fallback() {
    local option_value
    option_value="$(tmux show-option -gqv "$1")"
    if [ -z "$option_value" ]; then
        option_value="$2"
    fi
    echo "$option_value"
}

window_settings() {
    window_height=$(tmux_option_or_fallback "@fzfssh-window-height" "75%")
    window_width=$(tmux_option_or_fallback "@fzfssh-window-width" "75%")
    layout_mode=$(tmux_option_or_fallback "@fzfssh-layout" "default")
    prompt_icon=$(tmux_option_or_fallback "@fzfssh-prompt" "🔹 ")
    pointer_icon=$(tmux_option_or_fallback "@fzfssh-pointer" "▶")
    preview_enabled=$(tmux_option_or_fallback "@fzfssh-preview-enabled" "true")
    preview_location=$(tmux_option_or_fallback "@fzfssh-preview-location" "top")
    preview_ratio=$(tmux_option_or_fallback "@fzfssh-preview-ratio" "50%")
}

handle_binds() {
    bind_accept=$(tmux_option_or_fallback "@fzfssh-bind-accept" "enter")
    bind_exit=$(tmux_option_or_fallback "@fzfssh-bind-exit" "esc")
    bind_scroll_up=$(tmux_option_or_fallback "@fzfssh-bind-scroll-up" "ctrl-u")
    bind_scroll_down=$(tmux_option_or_fallback "@fzfssh-bind-scroll-down" "ctrl-d")
    bind_select_up=$(tmux_option_or_fallback "@fzfssh-bind-select-up" "ctrl-p")
    bind_select_down=$(tmux_option_or_fallback "@fzfssh-bind-select-down" "ctrl-n")
}

handle_args() {
    PREVIEW_LINE=""
    if [[ "$preview_enabled" == "true" ]]; then
        PREVIEW_LINE="$SCRIPTS_DIR/preview.sh {}"
    fi

    args=(
        --bind "$bind_accept:replace-query+print-query"
        --bind "$bind_exit:abort"
        --bind "$bind_select_up:up"
        --bind "$bind_select_down:down"
        --bind "$bind_scroll_up:preview-half-page-up"
        --bind "$bind_scroll_down:preview-half-page-down"
        --pointer "$pointer_icon"
        --layout "$layout_mode"
        --prompt "$prompt_icon"
        --preview "$PREVIEW_LINE"
        --preview-window "$preview_location,$preview_ratio,,"
        --height "$window_height"
        --width "$window_width"
        --exit-0
        --print-query
        --tac
        --scrollbar '▌▐'
    )
}

window_settings
handle_binds
handle_args
tmux set-option -g @fzfssh-_built-args "$(declare -p args)"

hotkey=$(tmux_option_or_fallback "@fzfssh-bind" "c-f")
prefix_on=$(tmux_option_or_fallback "@fzfssh-prefix" "on")

if [ "$prefix_on" = "on" ]; then
    tmux bind-key "$hotkey" run-shell "$CURRENT_DIR/scripts/fzfssh.sh"
else
    tmux bind-key -n "$hotkey" run-shell "$CURRENT_DIR/scripts/fzfssh.sh"
fi
