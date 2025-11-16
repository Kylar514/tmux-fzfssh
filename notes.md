# General Structure:

## fzfssh.tmux

- Sets default config for fzf
- sets keybinds in fzf
- sets window size
- sets options avail in tmux conf
- sets keybind for calling fzfssh in tmux

## fzfssh.sh

- Main fzf function.
- Addresses how to handle user input

## list\_\*.sh

- produces a list, for fzfssh.sh to display
- just a helper, that talks to the parsers

## parse\_\*.sh

- Parses .ssh/config and produces a list.
- core logic.

## preview\_\*.sh

- controls the content of preview for each list.

## actions

- Scripts that can be user made or built in.
  - things like scp push, and scp pull.

## File Structure

```
tmux-fzfssh/
├── fzfssh.tmux
└── scripts/
    ├── fzfssh.sh
    ├── list_default.sh
    ├── list_categories.sh
    ├── list_actions.sh
    ├── list_*.sh
    ├── actions/
    │   ├── action_scp_push.sh
    │   ├── action_scp_pull.sh
    │   ├── action_scp_dir_push.sh
    │   ├── action_scp_dir_pull.sh
    │   └── action_*.sh
    └── parsers/
        ├── parse_default.sh
        ├── parse_categories.sh
        ├── parse_actions.sh
        └── parse_*.sh
```
