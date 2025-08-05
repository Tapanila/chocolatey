import-module Chocolatey-AU

function global:au_GetLatest {
    $LatestRelease = Invoke-RestMethod -UseBasicParsing -Uri "https://github.com/Tapanila/SharpCaster/releases/latest"
    $LatestVersion = $LatestRelease.tag_name

    Write-Output "newversion=$($LatestVersion)" >> $Env:GITHUB_OUTPUT

    @{
        URL64        = $LatestRelease.assets | Where-Object {$_.name.EndsWith("-win-x64.exe")} | Select-Object -ExpandProperty browser_download_url
	URL64-ARM    = $LatestRelease.assets | Where-Object {$_.name.EndsWith("-win-x64.exe")} | Select-Object -ExpandProperty browser_download_url
        Version      = $LatestVersion
        ReleaseNotes = $LatestRelease.html_url
    }
}

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*(\$)url64\s*=\s*)('.*')"      = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }

        "elk-native.nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`$1$($Latest.ReleaseNotes)`$2"
        }
    }
}

update -ChecksumFor 64