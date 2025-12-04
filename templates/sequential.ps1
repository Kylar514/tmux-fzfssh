<#
.SYNOPSIS
    Template for running commands sequentially on multiple hosts.

.DESCRIPTION
    This template allows running SSH/remote tasks on multiple hosts **one at a time**.
    Useful for debugging, or when tasks must be executed in order.

.PARAMETER Targets
    The list of hostnames or IPs to run tasks on.

.EXAMPLE
    pwsh -File sequential-template.ps1 server1,server2,server3
#>

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Targets
)

# Ensure Targets is always an array
$Targets = @($Targets)

foreach ($target in $Targets) {
    $targetTrimmed = $target.Trim()
    Write-Host "[$targetTrimmed] Starting task..." -ForegroundColor Cyan

    try {
        # Example tasks (customize per use case):

        # SSH command
        ssh $targetTrimmed 'echo "Hello from $HOSTNAME"; hostname'

        # Rsync example (uncomment if needed)
        # rsync -avz user@$targetTrimmed:/remote/path /local/path

        # SCP example
        # scp user@$targetTrimmed:/remote/file /local/path

        # Compress-Archive example
        # Invoke-Command -ComputerName $targetTrimmed -ScriptBlock { Compress-Archive -Path C:\data -DestinationPath C:\data.zip }

        Write-Host "[$targetTrimmed] Task completed successfully." -ForegroundColor Green

    } catch {
        Write-Warning "[$targetTrimmed] Task failed: $_"
    }
}

Write-Host "All tasks /011 rw-r--r-- 1.2k Dec 04 09:43   notes.mdeted." -ForegroundColor Yellow
