param (
    [string]$Category  # optional
)

$sshJsonFile = "$HOME/.ssh/config.json"

if (-not (Test-Path $sshJsonFile))
{
    Write-Error "SSH JSON file not found at $sshJsonFile.  Run Convert to Json first."
}

$hosts = Get-Content $sshJsonFile | ConvertFrom-Json

if (-not $Category)
{
    $proxyAndCategories = @()

    foreach ($entry in $hosts)
    {
        if ($entry.ProxyJump)
        { $proxyAndCategories += $entry.ProxyJump 
        }
        if ($entry.Category)
        { $proxyAndCategories += $entry.Category 
        }
    }

    $uniqueProxyAndCategories = $proxyAndCategories | Sort-Object -Unique

    $valueWidth = 40
    $metaWidth = 40
    $meta = "Category"
    $formatString = "{0, -$valueWidth} {1, -$metaWidth}"

    foreach ($value in $uniqueProxyAndCategories)
    {
        Write-Output ($formatString -f $value, $meta)
    }

} else
{
    $hostAliasWidth = 25
    $commentWidth = 50
    $hostNameWidth = 15
    $proxyWidth = 20
    $metaWidth = 20
    $meta = "Host"
    $formatString = "{0, -$hostAliasWidth} {1, -$commentWidth} {2, -$hostNameWidth} {3, -$proxyWidth} {4, -$metaWidth}"

    $filteredHosts = $hosts | Where-Object { 
        $_.Category -eq $Category -or $_.ProxyJump -eq $Category 
    }

    foreach ($entry in $filteredHosts)
    {
        $hostAlias = $entry.Host
        $comment = $entry.Comment
        $hostName = $entry.Hostname
        $proxy = if ($entry.ProxyJump)
        { $entry.ProxyJump 
        } else
        { "-" 
        }

        Write-Output ($formatString -f $hostAlias, $comment, $hostName, $proxy, $meta)
    }
}
