$sshJsonFile = "$HOME/.ssh/config.json"

if (-not (Test-Path $sshJsonFile))
{
    Write-Error "SSH JSON file not found at $sshJsonFile.  Run Convert to Json first."
}

$hosts = Get-Content $sshJsonFile | ConvertFrom-Json

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
