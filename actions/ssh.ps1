#!/usr/bin/env pwsh

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$SshHosts
)

if ($SshHosts -isnot [System.Array]) {
    $SshHosts = @($SshHosts)
}

$InsideTmux = $env:TMUX -ne $null

foreach ($h in $SshHosts) {
    $hostTrimmed = $h.Trim()

    try {
        if ($InsideTmux) {
            tmux split-window -v "ssh $hostTrimmed"
        } else {
            Start-Process kitty -ArgumentList "--hold", "ssh $hostTrimmed"
        }

    } catch {
        Write-Warning "[$hostTrimmed] Failed to launch SSH: $_"
    }
}
