#!/usr/bin/env pwsh

param(
    [switch]$InsideTmux,    # Optional flag: are we inside tmux?
    [string]$Filter          # Optional filter for categories/ProxyJump
)

# -----------------------------
# Default Configuration
# -----------------------------
$pointerIcon    = "▶"
$layoutMode     = "default"
$promptIcon     = " "

# Header line for fzf display
$HEADER = "enter=󰿄  ctrl-a=󱂧  ctrl-c=󱂧  ctrl-m=  ctrl-n=󰌍  ctrl-p=  ctrl-u=  ctrl-d="

# Default fzf args (portable)
$defaultArgs = @(
    "--bind", "enter:accept",
    "--bind", "esc:abort",
    "--pointer", $pointerIcon,
    "--layout", $layoutMode,
    "--prompt", $promptIcon,
    "--header", $HEADER,
    "--exit-0",
    "--tac",
    "--scrollbar", "▌▐"
)

$fzfArgs = $defaultArgs

# -----------------------------
# Load tmux-specific args if requested
# -----------------------------
# if ($InsideTmux)
# {
# $tmuxArgsString = tmux show-option -gqv "@fzfssh-_built-args"
# if ($tmuxArgsString)
# {
# $tmuxArgs = $tmuxArgsString -split '\s+'
# $fzfArgs = $tmuxArgs
# } else
# {
# $fzfArgs = $defaultArgs
#     }
# } else
# {
#     $fzfArgs = $defaultArgs
# }

# -----------------------------
# Load SSH hosts from JSON
# -----------------------------
$sshJsonFile = "$HOME/.ssh/config.json"
if (-not (Test-Path $sshJsonFile))
{
    Write-Error "SSH JSON file not found at $sshJsonFile."
    exit
}

$hosts = Get-Content $sshJsonFile | ConvertFrom-Json

# -----------------------------
# Filter hosts by category/ProxyJump
# -----------------------------
if ($Filter -eq "Category")
{
    $values = @()
    foreach ($entry in $hosts)
    {
        if ($entry.ProxyJump)
        { $values += $entry.ProxyJump 
        }
        if ($entry.Category)
        { $values += $entry.Category 
        }
    }
    $hosts = $values | Sort-Object -Unique | ForEach-Object {
        [PSCustomObject]@{ Name = $_; Type = "Category" }
    }
} elseif ($Filter)
{
    $hosts = $hosts | Where-Object {
        $_.Category -eq $Filter -or $_.ProxyJump -eq $Filter
    }
}

# -----------------------------
# Build fzf display lines
# -----------------------------
$DELIM = [char]0x1F
$lines = $hosts | ForEach-Object {
    $json = ($_ | ConvertTo-Json -Compress -Depth 50)
    if ($_.Type -eq "Category")
    {
        $display = "{0,-40} {1}" -f $_.Name, $_.Type
    } else
    {
        $display = "{0,-25} {1,-45} {2,-16} {3,-12} {4}" -f `
            $_.Host, $_.Comment, $_.Hostname, `
        ($(if ($_.ProxyJump)
                { $_.ProxyJump 
                } else
                { "-" 
                })), `
            "Host"
    }
    "$display$DELIM$json"
}

# -----------------------------
# Run fzf
# -----------------------------
$selected = $lines | fzf @fzfArgs
if (-not $selected)
{ exit 
}

# Convert JSON back to objects
$selectedObjects = $selected -split "`n" | ForEach-Object {
    ($_.Split($DELIM))[1] | ConvertFrom-Json
}

# -----------------------------
# SSH connection logic
# -----------------------------

# foreach ($sshHost in $selectedObjects)
# {
#     $target = if ($sshHost.Hostname)
#     { $sshHost.Hostname 
#     } else
#     { $sshHost.Host 
#     }
#     Write-Host "Connecting to $($sshHost.Host) at $target..."
#
#     if ($InsideTmux)
#     {
#         tmux split-window -v "ssh $target"
#         # Start-Process kitty -ArgumentList "--hold", "ssh $target"
#         # tmux run-shell "tmux split-window -v 'ssh $target'"
#         exit
#     } else
#     {
#         # Start-Process ssh $target
#         # tmux split-window -v "ssh $target"
#         # Start-Process kitty -ArgumentList "--hold", "ssh $target"
#         # tmux run-shell "tmux split-window -v 'ssh $target'"
#         tmux split-window -v "ssh $target"
#         exit
#     }
# }
# Launch SSH for each selected host

# foreach ($sshHost in $selectedObjects)
# {
#     $target = $sshHost.Hostname ?? $sshHost.Host
#     Write-Host "Connecting to $($sshHost.Host) at $target..."
#
#     if ($InsideTmux)
#     {
#         tmux split-window -v "ssh $target"
#     } else
#     {
#         Start-Process kitty -ArgumentList "--hold", "ssh $target"
#     }
# }
#
# return

foreach ($sshHost in $selectedObjects)
{
    $target = $sshHost.Hostname ?? $sshHost.Host

    # Detached pane in main session
    tmux run-shell "tmux split-window -v 'ssh $target'"
}

# Script ends — popup closes
exit
