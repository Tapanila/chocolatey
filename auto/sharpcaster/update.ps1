import-module Chocolatey-AU

function global:au_GetLatest {
    $LatestRelease = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/Tapanila/SharpCaster/releases/latest"
    $LatestVersion = $LatestRelease.tag_name

    Write-Output "newversion=$($LatestVersion)" >> $Env:GITHUB_OUTPUT

    @{
        URL64        = $LatestRelease.assets | Where-Object {$_.name.EndsWith("-win-x64.exe")} | Select-Object -ExpandProperty browser_download_url
        Version      = $LatestVersion
        ReleaseNotes = $LatestRelease.html_url
    }
}

function global:au_BeforeUpdate {
    # Get the release data again since $LatestRelease is not available here
    $LatestRelease = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/Tapanila/SharpCaster/releases/latest"
    
    # Get ARM URL from the same release
    $armUrl = $LatestRelease.assets | Where-Object {$_.name.EndsWith("-win-arm.exe")} | Select-Object -ExpandProperty browser_download_url
    
    # Download and calculate checksums
    $tempDir = "$env:TEMP\sharpcaster-checksums"
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    $x64File = "$tempDir\sharpcaster-win-x64.exe"
    $armFile = "$tempDir\sharpcaster-win-arm.exe"
    
    Write-Host "Downloading x64 version for checksum calculation..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $Latest.URL64 -OutFile $x64File -UseBasicParsing
    $Latest.Checksum64 = (Get-FileHash $x64File -Algorithm SHA256).Hash
    
    if ($armUrl) {
        Write-Host "Downloading ARM version for checksum calculation..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $armUrl -OutFile $armFile -UseBasicParsing
        $Latest.ChecksumARM = (Get-FileHash $armFile -Algorithm SHA256).Hash
        $Latest.URLARM = $armUrl
    }    
    # Clean up
    Remove-Item $tempDir -Recurse -Force
}

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(https://github\.com/Tapanila/SharpCaster/releases/download/[^']*sharpcaster-win-x64\.exe)" = "$($Latest.URL64)"
            "(https://github\.com/Tapanila/SharpCaster/releases/download/[^']*sharpcaster-win-arm\.exe)" = "$($Latest.URLARM)"
            "(\`$checksum64\s*=\s*')([A-F0-9]*)('.*# x64)" = "`$1$($Latest.Checksum64)`$3"
            "(\`$checksum64\s*=\s*')([A-F0-9]*)('.*# ARM)" = "`$1$($Latest.ChecksumARM)`$3"
        }

        "sharpcaster.nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`$1$($Latest.ReleaseNotes)`$2"
        }
    }
}

update -ChecksumFor none