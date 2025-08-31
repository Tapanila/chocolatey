$ErrorActionPreference = 'Stop'

$packageName = 'sharpcaster'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Define release URLs and checksums for each architecture
$urlX64      = 'https://github.com/Tapanila/SharpCaster/releases/download/3.0.0/sharpcaster-win-x64.exe'
$checksumX64 = 'EB995E6D1A049D08BDC4BF83B9B484419D8CE5D80D65726BADF1801F78CA16F3' # x64
$urlARM      = 'https://github.com/Tapanila/SharpCaster/releases/download/3.0.0/sharpcaster-win-arm.exe'
$checksumARM = '2CF5895B9149642AA86E05D9FBA3A0E298D9E0C1CAD0A6258061AB775EDC68FE' # ARM

# Detect architecture and choose the proper download
$processorArch = $env:PROCESSOR_ARCHITECTURE
if ($processorArch -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') {
    $downloadUrl = $urlARM
    $checksum    = $checksumARM
    $archSuffix  = 'arm64'
    Write-Host 'Detected ARM64 architecture, downloading ARM64 version...' -ForegroundColor Yellow
} else {
    $downloadUrl = $urlX64
    $checksum    = $checksumX64
    $archSuffix  = 'x64'
    Write-Host 'Detected x64 architecture, downloading x64 version...' -ForegroundColor Yellow
}

# Download the executable with checksum validation
$filePath = Join-Path $toolsDir 'sharpcaster.exe'
Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $filePath -Url $downloadUrl -Checksum $checksum -ChecksumType 'sha256'

# Create a shim for the executable
Install-BinFile -Name 'sharpcaster' -Path $filePath

Write-Host "SharpCaster ($archSuffix) has been installed successfully!" -ForegroundColor Green
Write-Host "You can now use 'sharpcaster' command from anywhere in your terminal." -ForegroundColor Yellow
Write-Host "Run 'sharpcaster --help' to get started." -ForegroundColor Yellow
