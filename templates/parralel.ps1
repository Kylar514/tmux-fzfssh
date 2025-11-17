<#
.SYNOPSIS
    Template for running commands in parallel on multiple hosts.

.DESCRIPTION
    This template allows running SSH/remote tasks on multiple hosts in parallel.
    It includes user-configurable maximum parallel jobs to avoid overloading the network.

.PARAMETER Targets
    The list of hostnames or IPs to run tasks on.

.PARAMETER MaxParallel
    Maximum number of jobs to run simultaneously. Default is 10.

.EXAMPLE
    pwsh -File parallel-template.ps1 server1,server2,server3 -MaxParallel 5
#>

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Targets,

    [int]$MaxParallel = 10
)

# Ensure Targets is always an array
$Targets = @($Targets)

# Semaphore to control max parallel jobs
$semaphore = [System.Threading.SemaphoreSlim]::new($MaxParallel, $MaxParallel)

# Array to hold job objects
$jobs = @()

foreach ($target in $Targets) {
    $targetTrimmed = $target.Trim()

    # Wait if max parallel jobs are running
    $semaphore.Wait()

    $jobs += Start-Job -Name $targetTrimmed -ScriptBlock {
        param($h, $sem)

        try {
            Write-Host "[$h] Starting task..." -ForegroundColor Cyan

            # Example tasks (customize per use case):
            # SSH command
            ssh $h 'echo "Hello from $HOSTNAME"; hostname'

            # Rsync example (uncomment if needed)
            # rsync -avz user@$h:/remote/path /local/path

            # SCP example
            # scp user@$h:/remote/file /local/path

            # Compress-Archive example
            # Invoke-Command -ComputerName $h -ScriptBlock { Compress-Archive -Path C:\data -DestinationPath C:\data.zip }

            Write-Host "[$h] Task completed successfully." -ForegroundColor Green

        } catch {
            Write-Warning "[$h] Task failed: $_"
        } finally {
            # Release the semaphore slot when done
            $sem.Release() | Out-Null
        }

    } -ArgumentList $targetTrimmed, $semaphore
}

# Wait for all jobs to finish
Write-Host "Waiting for all $($jobs.Count) jobs to complete..."
Wait-Job -Job $jobs

# Collect output
$jobs | ForEach-Object {
    Receive-Job -Job $_
    Remove-Job -Job $_
}

Write-Host "All tasks completed." -ForegroundColor Yellow
