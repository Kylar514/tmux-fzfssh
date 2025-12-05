# HostActions

**HostActions** is an interactive, FZF-driven PowerShell ssh host automation tool
for managing and executing actions across one or many SSH hosts—either
sequentially or in parallel.

It is designed for:

- Fleet-wide automation
- SSH-based task execution
- SCP / rsync workflows
- System reporting
- DevOps-style orchestration
- High-volume host management

---

## Getting Started

### Dependencies

- Powershell Core
- fzf

Clone the repository:

```bash
git clone https://github.com/Kylar514/HostActions.git
cd HostActions
```

---

### Option 1 — PowerShell Native (Recommended)

- Add `Import-Module /path/to/dir/HostActions/` To Powershell profile
  **or**
- Place the repo in your PowerShell modules directory, that is imported in your profile

This allows you to run `Start-HostActions` directly from any PowerShell session.

---

### Option 2 — Bash / Zsh Users

Create an alias that runs the script through PowerShell:

```bash
alias Start-HostActions="pwsh -Command Start-HostActions"
```

> Important: This project **must** be executed using `pwsh`, even when launched
> from Bash or Zsh.
> NOTE this the module needs to still be imported to your powershell profile

---

### Option 3 — Tmux Users

Add the following to your `~/.tmux.conf`, then reload tmux:

```tmux
bind-key c-f run-shell "pwsh -Command Start-HostActions"
```

> Make sure `pwsh` is explicitly included in the command.
> NOTE this the module needs to still be imported to your powershell profile

Reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

---

## ConvertJson

This utility converts your existing SSH config into the JSON format used by
HostActions.

### Expected File Locations

- SSH config input:
  ```
  ~/.ssh/config
  ```
- Generated JSON output:
  ```
  ~/.ssh/config.json
  ```

### Current Expected SSH Config Format

> This format will likely be simplified in the future.

```ssh
# <empty line between each host>

Host <HOST_ALIAS>
    HostName <HOST_IP>
    User <HOST_USER>
    IdentityFile <SSH_KEY_PATH>
    ProxyJump <PROXY_JUMP_IF_APPLICABLE>   # Also used as a category if present
    # Category Personal                   # Custom category (free-form)
    # Router                              # Free-form comment for FZF searching

# <empty line between each host>
```

- `ProxyJump` is automatically treated as a **category** if present.
- `# Category <Name>` is used for custom grouping.
- Any other comments are included as searchable notes in FZF.

---

## Features

- Interactive host selection via **fzf**
- Category-based filtering
- Supports **single or multi-host execution**
- Modular **action system**
- Built-in **Sequential & Parallel execution templates**
- Configurable **MaxParallel throttle control**
- Works with:
  - SSH
  - SCP
  - rsync
  - Remote command execution
  - Remote reporting
- User-extensible without modifying core logic

---

## Project Structure

```
HostActions/
├── HostActions.ps1
├── ConvertJson.ps1
├── Templates/
│   ├── Parallel_Template.ps1
│   └── Sequential_Template.ps1
└── actions/
    ├── ssh.ps1
    └── action_*.ps1
```

---

## Core Components

### `HostActions.ps1`

Responsibilities:

- Parses SSH config JSON
- Displays hosts and categories using **fzf**
- Handles:
  - Single or multiple host selection
  - Category-based filtering
- Launches:
  - User-selected **actions**
  - Built-in **templates**
- Manages:
  - Input parsing
  - Action routing
  - Multi-host dispatch

---

## Templates

Templates define **how actions run**.

---

### `Templates/Sequential_Template.ps1`

- Executes one host at a time
- Used for:
  - Step-by-step deployments
  - Debugging
  - Ordered automation
  - Operations that must not overlap

---

### `Templates/Parallel_Template.ps1`

- Executes across many hosts **simultaneously**
- Includes:
  - `-MaxParallel` throttle control
  - Job queue + semaphore logic
- Used for:
  - rsync
  - scp
  - Reporting
  - Compression + retrieval
  - Fleet-wide health checks
  - Large-scale automation

---

## Actions System

The `actions/` directory contains **user-defined scripts** that are launched by
`HostActions.ps1`.

### Characteristics:

- Actions receive **one or more host arguments**
- Can be:
  - Sequential
  - Parallel
  - Hybrid

### Example Actions:

- `action_scp_dir_push.sh`
- `action_scp_dir_pull.sh`
- `action_parallel_report.ps1`
- `action_ssh_tmux.ps1`
- `action_rsync.ps1`

---

## Parallel Reporting Example Use Case

- SSH into 150 machines
- Run:
  - Memory audit
  - Disk usage report
  - PowerShell / Node / PM2 version checks
  - Open port scan
- Save each system’s output to JSON
- Aggregate into a single master report

---

## 🛠 Execution Models

| Mode       | Behavior                  | Use Case                    |
| ---------- | ------------------------- | --------------------------- |
| Sequential | One host at a time        | Deployments, ordered tasks  |
| Parallel   | Many hosts simultaneously | Reports, rsync, SCP, audits |

---

## Design Goals

- Interactive DevOps workflows
- Zero-lock-in action system
- Easy scaling from 1 → 150+ hosts
- Safe parallel execution
- Clean separation:
  - Core engine
  - Templates
  - Actions
- Scriptable & composable automation

---

## Future Roadmap (Optional / Planned)

- [ ] Better terminal and cross platform support

---

## License

MIT

---

## Summary

**HostActions** gives you:

- A powerful interactive host selector
- Modular execution strategies
- Massive parallel automation potential
- A clean, extensible DevOps-grade framework

Built for:

- Sysadmins
- SREs
- Homelabs
- Infrastructure automation
- Network operations
