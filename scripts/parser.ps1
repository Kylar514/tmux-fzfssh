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

$hostAliasWidth = 25
$commentWidth = 50
$hostNameWidth = 15
$proxyWidth = 20
$metaWidth = 20

$valueWidth = 40
$categoryMetaWidth = 40

if (-not $Filter)
{
    foreach ($entry in $hosts)
    {
        $hostAlias = $entry.Host
        $comment = $entry.Comment
        $hostName = $entry.Hostname
        $proxy = if ($entry.ProxyJump)
        { $entry.ProxyJump 
        } else
        { "-" 
        }
        $meta = "Host"
        $formatString = "{0, -$hostAliasWidth} {1, -$commentWidth} {2, -$hostNameWidth} {3, -$proxyWidth} {4, -$metaWidth}"
        Write-Output ($formatString -f $hostAlias, $comment, $hostName, $proxy, $meta)
    }
} elseif ($Filter -eq "Category")
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
    $meta = "Category"
    $formatString = "{0, -$valueWidth} {1, -$categoryMetaWidth}"

    foreach ($value in $uniqueProxyAndCategories)
    {
        Write-Output ($formatString -f $value, $meta)
    }
} else
{
    $filteredHosts = $hosts | Where-Object { 
        $_.Category -eq $Filter -or $_.ProxyJump -eq $Filter 
    }

    $meta = "Host"
    $formatString = "{0, -$hostAliasWidth} {1, -$commentWidth} {2, -$hostNameWidth} {3, -$proxyWidth} {4, -$metaWidth}"

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
