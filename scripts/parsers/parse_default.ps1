$sshJsonFile = "$HOME/.ssh/config.json"

if (-not (Test-Path $sshJsonFile))
{
    Write-Error "SSH JSON file not found at $sshJsonFile.  Run Convert to Json first."
}

$hosts = Get-Content $sshJsonFile | ConvertFrom-Json

foreach ($entry in $hosts)
{
    $hostAliasWidth = 25
    $commentWidth = 50
    $hostNameWidth = 15
    $proxyWidth = 20

    $hostAlias = $entry.Host
    $comment = $entry.Comment
    $hostName = $entry.Hostname
    $proxy = if ($entry.ProxyJump)
    { $entry.ProxyJump 
    } else
    { "-"
    }

    $formatString = "{0, -$hostAliasWidth} {1, -$commentWidth} {2, -$hostNameWidth} {3, $proxyWidth}"

    Write-Output ($formatString -f $hostAlias, $comment, $hostName, $proxy)
}
