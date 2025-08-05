$ErrorActionPreference = 'Stop'

$packageName = 'sharpcaster'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Detect architecture and set appropriate download URL
$processorArch = $env:PROCESSOR_ARCHITECTURE

if ($processorArch -eq "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -eq "ARM64") {
    $url64bit = 'https://github.com/Tapanila/SharpCaster/releases/download/3.0.0-beta5/sharpcaster-win-arm.exe'
    $checksum64 = 'C7B38A5B0E9FD43787DB381AA813BAFFF09C35FD2AE7AEC460D57897B319DFA1' # ARM
    $archSuffix = 'arm64'
    Write-Host "Detected ARM64 architecture, downloading ARM64 version..." -ForegroundColor Yellow
} else {
    $url64bit = 'https://github.com/Tapanila/SharpCaster/releases/download/3.0.0-beta5/sharpcaster-win-x64.exe'
    $checksum64 = '9B4E8D52945B4C74DC91F6AA42F7272F0A6811C2441C45A3F36C43DD4AC17F34' # x64
    $archSuffix = 'x64'
    Write-Host "Detected x64 architecture, downloading x64 version..." -ForegroundColor Yellow
}

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url64bit      = $url64bit
  softwareName  = 'sharpcaster*'
  checksum64    = $checksum64
  checksumType64= 'sha256'
  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0)
}

# Download and install the executable
$filePath = Join-Path $toolsDir 'sharpcaster.exe'
Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $filePath -Url64bit $url64bit -Checksum64 $checksum64 -ChecksumType64 $packageArgs.checksumType64

# Create a shim for the executable
Install-BinFile -Name 'sharpcaster' -Path $filePath

Write-Host "SharpCaster ($archSuffix) has been installed successfully!" -ForegroundColor Green
Write-Host "You can now use 'sharpcaster' command from anywhere in your terminal." -ForegroundColor Yellow
Write-Host "Run 'sharpcaster --help' to get started." -ForegroundColor Yellow
