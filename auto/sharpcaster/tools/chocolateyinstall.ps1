$ErrorActionPreference = 'Stop'

$packageName = 'sharpcaster'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Detect architecture and set appropriate download URL
$processorArch = $env:PROCESSOR_ARCHITECTURE

if ($processorArch -eq "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -eq "ARM64") {
    $url64bit = 'https://github.com/Tapanila/SharpCaster/releases/download/3.0.0/sharpcaster-win-arm.exe'
    $checksum64 = '2CF5895B9149642AA86E05D9FBA3A0E298D9E0C1CAD0A6258061AB775EDC68FE' # ARM
    $archSuffix = 'arm64'
    Write-Host "Detected ARM64 architecture, downloading ARM64 version..." -ForegroundColor Yellow
} else {
    $url64bit = 'https://github.com/Tapanila/SharpCaster/releases/download/3.0.0/sharpcaster-win-x64.exe'
    $checksum64 = 'EB995E6D1A049D08BDC4BF83B9B484419D8CE5D80D65726BADF1801F78CA16F3' # x64
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
