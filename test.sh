source ~/projects/tmux-fzfssh/fzfssh.tmux

selected=$(ls ~/ | fzf "${args[@]}")

echo "You selected: $selected"
