# Copyright 2026 Factory-X Consortia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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