#!/usr/bin/env pwsh

param(
    [string]$Filter,
    [switch]$ListOnly
)

$ConfigFile = "$HOME/.ssh/config.json"
$fmt = "{0,-25} {1,-40} {2,-16} {3,-15} {4,-10}"

$script:CachedConfig = $null

function Get-Substring($s, [int]$start, [int]$len) {
    if (-not $s) { 
        return "" 
    }
    if ($s.Length -le $start) { 
        return "" 
    }
    $max = [Math]::Min($len, $s.Length - $start)
    return $s.Substring($start, $max)
}

function Format-HostLine($obj) {
    return $fmt -f $obj.Host, $obj.Comment, $obj.HostName, $obj.Id, $obj.Type
}

function Import-HostConfig {
    if ($script:CachedConfig) {
        return $script:CachedConfig
    }

    if (!(Test-Path $ConfigFile)) {
        Write-Error "Missing config.json"
        exit 1
    }

    $json = Get-Content $ConfigFile -Raw | ConvertFrom-Json

    $hosts = $json | ForEach-Object {
        $id = if ($_.Category) {
            $_.Category 
        } elseif ($_.ProxyJump) {
            $_.ProxyJump 
        } else { 
            "" 
        }

        [PSCustomObject]@{
            Host     = $_.Host
            Comment  = $_.Comment
            HostName = $_.HostName
            User     = $_.User
            Key      = $_.IdentityFile
            Proxy    = $_.ProxyJump
            Category = $_.Category
            Id       = $id
            Type     = "Host"
        }
    }

    $categories = $hosts |
        ForEach-Object { $_.Id } |
        Where-Object { $_ -ne "" } |
        Sort-Object -Unique |
        ForEach-Object {
            [PSCustomObject]@{
                Host     = ""
                Comment  = ""
                HostName = ""
                Category = $_
                Id       = $_
                Type     = "Category"
            }
        }

    $script:CachedConfig = @{
        Hosts      = $hosts
        Categories = $categories
    }

    return $script:CachedConfig
}

function Get-HostsByCategory($ids) {
    $data = Import-HostConfig
    return $data.Hosts | Where-Object { $_.Id -in $ids }
}

function Get-Hostlines([object]$Filter) {
    $data = Import-HostConfig
    $hosts = $data.Hosts
    $categories = $data.Categories

    if (-not $Filter) {
        return $hosts | ForEach-Object { Format-HostLine $_ }
    }

    if ($Filter -eq "Category") {
        return $categories | ForEach-Object {
            $fmt -f $_.Id, "", "", $_.Id, $_.Type
        }
    }

    if ($Filter -is [System.Array]) {
        return (Get-HostsByCategory $Filter) | ForEach-Object { Format-HostLine $_ }
    }

    if ($Filter -is [string] -and $Filter -match ",") {
        $ids = $Filter -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        return (Get-HostsByCategory $ids) | ForEach-Object { Format-HostLine $_ }
    }

    return ($hosts | Where-Object { $_.Id -eq $Filter }) |
        ForEach-Object { Format-HostLine $_ }
}

function Convert-LineToObject($line) {
    if (-not $line) { 
        return $null 
    }

    return [PSCustomObject]@{
        Host     = (Get-Substring $line 0 25).Trim()
        Comment  = (Get-Substring $line 25 40).Trim()
        HostName = (Get-Substring $line 65 16).Trim()
        Id       = (Get-Substring $line 81 15).Trim()
        Type     = (Get-Substring $line 96 15).Trim()
    }
}

function Invoke-Fzf([string[]]$lines) {
    if (-not $lines -or $lines.Count -eq 0) { 
        return $null 
    }

    $scriptQuoted = '"' + $PSCommandPath + '"'

    $fzfArgs = @(
        "--header", "enter=select • ctrl-a=All • ctrl-c=Categories"
        "--prompt", "Select> "
        "--border"
        "--tmux"
        "--exit-0"
        "--multi"
        "--tac"
        "--bind=ctrl-a:reload(pwsh -NoProfile -Command ""$scriptQuoted -ListOnly -Filter ''"" )"
        "--bind=ctrl-c:reload(pwsh -NoProfile -Command ""$scriptQuoted -ListOnly -Filter Category"" )"
    )

    return $lines | fzf @fzfArgs
}

function Invoke-HostActions($parsedObjects) {
    $allHosts = @()
    foreach ($obj in $parsedObjects) {
        if (-not $obj) { 
            continue 
        }

        if ($obj.Type -eq "Category") {
            $hosts = Get-HostsByCategory $obj.Id
            if (-not $hosts) {
                continue 
            }

            $lines = $hosts | ForEach-Object { Format-HostLine $_ }
            $sel = Invoke-Fzf $lines
            if (-not $sel) { 
                continue 
            }

            $allHosts += ($sel -split "`n" | ForEach-Object { Convert-LineToObject $_ })
        } elseif ($obj.Type -eq "Host") {
            $allHosts += $obj
        }
    }

    if (-not $allHosts) {
        Write-Host "No hosts selected."
        exit
    }

    $chosenAction = Get-ChildItem "$PSScriptRoot/actions" -File |
        ForEach-Object { $_.Name } |
        fzf @(
            "--header", "Select action for all hosts"
            "--prompt", "Action> "
            "--border"
            "--tmux"
            "--exit-0"
        )

    if (-not $chosenAction) { exit }

    $hostArgs = @($allHosts | ForEach-Object { $_.Host })

    pwsh -NoProfile -File (Join-Path "$PSScriptRoot/actions" $chosenAction) @hostArgs
}

if ($ListOnly) { 
    Get-Hostlines $Filter
    exit
}

$lines = Get-Hostlines $Filter
if (-not $lines) { 
    exit 
}

$selectedLines = Invoke-Fzf $lines
if (-not $selectedLines){
    exit 
}

$firstParsed = $selectedLines -split "`n" | ForEach-Object { Convert-LineToObject $_ }

$selectedCategories = $firstParsed | Where-Object { $_.Type -eq "Category" }

if ($selectedCategories) {
    $ids = $selectedCategories | ForEach-Object { $_.Id } | Sort-Object -Unique

    $hosts = Get-HostsByCategory $ids
    if (-not $hosts) {
        Write-Host "No hosts found for selected categories."
        exit
    }

    $lines2 = $hosts | ForEach-Object { Format-HostLine $_ }
    $selection2 = Invoke-Fzf $lines2
    if (-not $selection2) {
        exit 
    }

    $parsedSelection2 = $selection2 -split "`n" | ForEach-Object { Convert-LineToObject $_ }
    Invoke-HostActions $parsedSelection2
    exit
}

Invoke-HostActions $firstParsed
