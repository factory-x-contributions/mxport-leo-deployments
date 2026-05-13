$ErrorActionPreference = "Stop"

# Configuration
$Url = "https://github.com/eclipse-aaspe/package-explorer/releases/download/v2025-03-25.alpha/aasx-package-explorer-small.2025-03-25.alpha.zip"
$BaseDir = "$PSScriptRoot\aasx-package-explorer"
$ZipPath = "$BaseDir\aasx-package-explorer.zip"
$ExePath = "$BaseDir\AasxPackageExplorer\AasxPackageExplorer.exe"

# Create target directory
New-Item -ItemType Directory -Force -Path $BaseDir | Out-Null

# Download ZIP
Write-Host "Downloading AASX Package Explorer..."
Invoke-WebRequest -Uri $Url -OutFile $ZipPath

# Unzip
Write-Host "Extracting..."
Expand-Archive -Path $ZipPath -DestinationPath $BaseDir -Force

# Start application
Write-Host "Starting AASX Package Explorer..."
Start-Process -FilePath $ExePath