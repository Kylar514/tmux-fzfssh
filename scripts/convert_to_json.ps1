$sshConfig = "$HOME\.ssh\config"
$outputFile = "$HOME/.ssh/config.json"

$lines = Get-Content $sshConfig -ErrorAction Stop

$hosts = @()
$hostEntry = $null
$pendingComment = $null

foreach ($line in $lines)
{
    $trimmed = $line.Trim()

    if ([string]::IsNullOrWhiteSpace($trimmed))
    {
        $pendingComment = $null
        continue
    }

    if ($trimmed -match '^#\s*category\s+(.+)$')
    {
        $pendingComment = @{Category = $matches[1]; Comment = $null}
        continue
    } elseif ($trimmed -match '^#\s*(.+)$' -and $trimmed -notmatch '^#+[- ]+$')
    {
        $pendingComment = @{Category = $null; Comment = $matches[1]}
        continue
    }

    if ($trimmed -match '^Host\s+(.+)$')
    {
        if ($hostEntry -and $hostEntry.Host)
        { $hosts += $hostEntry 
        }
        
        $hostEntry = [ordered]@{
            Host = $matches[1]
            HostName = $null
            User = $null
            IdentityFile = $null
            ProxyJump = $null
            Category = $null
            Comment = $null
        }

        if ($pendingComment)
        {
            $hostEntry.Category = $pendingComment.Category
            $hostEntry.Comment  = $pendingComment.Comment
            $pendingComment = $null
        }
        continue
    }

    if (-not $hostEntry)
    { continue 
    }

    if ($trimmed -match '^HostName\s+(.+)$')
    { $hostEntry.HostName = $matches[1] 
    } elseif ($trimmed -match '^User\s+(.+)$')
    { $hostEntry.User = $matches[1] 
    } elseif ($trimmed -match '^IdentityFile\s+(.+)$')
    { $hostEntry.IdentityFile = $matches[1] 
    } elseif ($trimmed -match '^ProxyJump\s+(.+)$')
    { $hostEntry.ProxyJump = $matches[1] 
    }
}

if ($hostEntry -and $hostEntry.Host)
{ $hosts += $hostEntry 
}

$hosts | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $outputFile
Write-Output "SSH config converted to JSON at $outputFile"
