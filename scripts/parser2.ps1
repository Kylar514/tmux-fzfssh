param (
    [string]$Filter
)

$sshJsonFile = "$HOME/.ssh/config.json"

if (-not (Test-Path $sshJsonFile))
{
    Write-Error "SSH JSON file not found at $sshJsonFile. Run Convert to Json first."
    return
}

$hosts = Get-Content $sshJsonFile | ConvertFrom-Json

if (-not $Filter)
{
    return $hosts
}

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

    $unique = $values | Sort-Object -Unique

    return $unique | ForEach-Object {
        [PSCustomObject]@{
            Name  = $_
            Type  = "Category"
        }
    }
}

return $hosts | Where-Object {
    $_.Category -eq $Filter -or $_.ProxyJump -eq $Filter
}
