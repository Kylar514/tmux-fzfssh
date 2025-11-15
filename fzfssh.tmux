#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"
ACTIONS_DIR="$CURRENT_DIR/scripts/actions"

# source "$SCRIPTS_DIR/parser.sh"
# source "$SCRIPTS_DIR/actions.sh"

tmux_option() {
    local option_value
    option_value="$(tmux show-option -gqv "$1")"
    if [ -z "$option_value" ]; then
        option_value="$2"
    fi
    echo "$option_value"
}

window_settings() {
    window_height=$(tmux_option "@fzfssh-window-height" "75%")
    window_width=$(tmux_option "@fzfssh-window-width" "75%")
    layout_mode=$(tmux_option "@fzfssh-layout" "default")
    pointer_icon=$(tmux_option "@fzfssh-pointer" "▶")
    preview_enabled=$(tmux_option "@fzfssh-preview-enabled" "true")
    preview_location=$(tmux_option "@fzfssh-preview-location" "top")
    preview_ratio=$(tmux_option "@fzfssh-preview-ratio" "50%")
	prompt_icon=$(tmux_option "@sessionx-prompt" " ")
}

handle_binds() {
    bind_accept=$(tmux_option "@fzfssh-bind-accept" "enter")
    bind_exit=$(tmux_option "@fzfssh-bind-exit" "esc")
    bind_scroll_up=$(tmux_option "@fzfssh-bind-scroll-up" "ctrl-u")
    bind_scroll_down=$(tmux_option "@fzfssh-bind-scroll-down" "ctrl-d")
    bind_select_up=$(tmux_option "@fzfssh-bind-select-up" "ctrl-p")
    bind_select_down=$(tmux_option "@fzfssh-bind-select-down" "ctrl-n")
    bind_all_hosts=$(tmux_option "@fzfssh-bind-all-hosts" "ctrl-h")
    bind_category=$(tmux_option "@fzfssh-bind-category" "ctrl-c")
    bind_multi_ssh=$(tmux_option "@fzfssh-bind-multi-ssh" "ctrl-m")
    bind_actions=$(tmux_option "@fzfssh-bind-actions" "ctrl-a")
    bind_custom_command=$(tmux_option "@fzfssh-bind-custom-command" "ctrl-n")
}

handle_args() {
    PREVIEW_LINE=""
    if [[ "$preview_enabled" == "true" ]]; then
        PREVIEW_LINE="$SCRIPTS_DIR/preview.sh {}"
    fi

	HEADER="$bind_accept=󰿄  $bind_all_hosts=󱂧  $bind_category=󱂧  $bind_multi_ssh=  $bind_actions=󱃖  $bind_custom_command=󰌍  $bind_scroll_up=  $bind_scroll_down= "

    if [ -n "$TMUX" ]; then
        fzf_size_arg=(--tmux)
    else
        fzf_size_arg=()
    fi

    args=(
        --bind "$bind_accept:replace-query+print-query"
        --bind "$bind_exit:abort"
        --bind "$bind_select_up:up"
        --bind "$bind_select_down:down"
        --bind "$bind_scroll_up:preview-half-page-up"
        --bind "$bind_scroll_down:preview-half-page-down"
        # --bind "$bind_all_hosts:all-hosts"
        # --bind "$bind_category:category"
        # --bind "$bind_multi_ssh:multi_ssh"
        # --bind "$bind_actions:actions"
        # --bind "$bind_custom_command:custom-command"
        --pointer "$pointer_icon"
        --layout "$layout_mode"
        --prompt "$prompt_icon"
        --header "$HEADER"
        --preview "$PREVIEW_LINE"
        --preview-window "$preview_location,$preview_ratio,,"
        "${fzf_size_arg[@]}"
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

hotkey=$(tmux_option "@fzfssh-bind" "c-f")
prefix_on=$(tmux_option "@fzfssh-prefix" "on")

if [ "$prefix_on" = "on" ]; then
    tmux bind-key "$hotkey" run-shell "$CURRENT_DIR/scripts/fzfssh.sh"
else
    tmux bind-key -n "$hotkey" run-shell "$CURRENT_DIR/scripts/fzfssh.sh"
fi
