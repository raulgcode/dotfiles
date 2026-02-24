#===============================================================================
# Development Tools Installation for Windows
#===============================================================================

function Install-Python {
    Write-Step "Installing Python..."
    
    if (Test-Command python) {
        $version = Get-ProgramVersion "python" "--version"
        Write-Success "Python is already installed: $version"
        Add-Skipped "Python" "Already installed"
        return $true
    }
    
    # Try winget first
    if (Test-Command winget) {
        if (Install-WingetPackage "Python.Python.3.12" "Python 3.12") {
            Write-Success "Python installed via Winget"
            Add-Success "Python"
            
            # Upgrade pip
            Upgrade-Pip
            return $true
        }
    }
    
    # Fallback to chocolatey
    if (Test-Command choco) {
        if (Install-ChocoPackage "python") {
            Write-Success "Python installed via Chocolatey"
            Add-Success "Python"
            
            # Upgrade pip
            Upgrade-Pip
            return $true
        }
    }
    
    Write-Error-Custom "Failed to install Python"
    Add-Failure "Python" "No package manager available"
    return $false
}

function Upgrade-Pip {
    if (Test-Command python) {
        Write-Step "Upgrading pip..."
        try {
            python -m pip install --upgrade pip 2>&1 | Out-Null
            $version = Get-ProgramVersion "pip" "--version"
            Write-Success "pip upgraded: $version"
        }
        catch {
            Write-Warning-Custom "Could not upgrade pip"
        }
    }
}

function Install-NVMWindows {
    Write-Step "Installing nvm-windows (Node Version Manager)..."
    
    if (Test-Command nvm) {
        Write-Success "nvm-windows is already installed"
        Add-Skipped "nvm-windows" "Already installed"
        
        # Check if Node.js is already installed
        $nodeVersion = nvm current 2>&1 | Select-String -Pattern "v\d"
        if ($nodeVersion) {
            Write-Success "Node.js via nvm: $nodeVersion"
        } else {
            Write-Info "No Node.js version selected. Install one with: nvm install lts"
        }
        return $true
    }
    
    Write-Step "Downloading nvm-windows installer..."
    
    try {
        $NVMInstallDir = "$env:PROGRAMFILES\nvm"
        $NVMDownloadUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.11/nvm-setup.exe"
        $TempFile = Join-Path $env:TEMP "nvm-setup.exe"
        
        if (Get-RemoteFile $NVMDownloadUrl $TempFile) {
            Write-Step "Running nvm-windows installer..."
            Start-Process -FilePath $TempFile -NoNewWindow -Wait
            
            # Clean up
            Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
            
            # Verify installation
            if (Test-Command nvm) {
                Write-Success "nvm-windows installed successfully"
                Add-Success "nvm-windows"
                
                # Install Node.js LTS
                Write-Step "Installing Node.js LTS via nvm..."
                nvm install lts 2>&1 | Out-Null
                nvm use lts 2>&1 | Out-Null
                
                if (Test-Command node) {
                    $nodeVersion = Get-ProgramVersion "node" "--version"
                    $npmVersion = Get-ProgramVersion "npm" "--version"
                    Write-Success "Node.js installed: $nodeVersion"
                    Write-Success "npm installed: $npmVersion"
                    Add-Success "Node.js LTS"
                }
                
                return $true
            }
            else {
                Write-Warning-Custom "nvm-windows installation completed but command not available yet"
                Write-Info "You may need to restart PowerShell or your computer"
                Add-Skipped "nvm-windows" "Installation may require restart"
                return $false
            }
        }
        else {
            Write-Error-Custom "Failed to download nvm-windows"
            Add-Failure "nvm-windows" "Download failed"
            return $false
        }
    }
    catch {
        Write-Error-Custom "Failed to install nvm-windows: $_"
        Add-Failure "nvm-windows" "Installation failed: $_"
        return $false
    }
}

function Install-GitHubCLI {
    Write-Step "Installing GitHub CLI..."
    
    if (Test-Command gh) {
        $version = Get-ProgramVersion "gh" "--version"
        Write-Success "GitHub CLI is already installed: $version"
        Add-Skipped "GitHub CLI" "Already installed"
        return $true
    }
    
    # Try winget first
    if (Test-Command winget) {
        if (Install-WingetPackage "GitHub.cli" "GitHub CLI") {
            Write-Success "GitHub CLI installed via Winget"
            Add-Success "GitHub CLI"
            Write-Info "Run 'gh auth login' to authenticate"
            return $true
        }
    }
    
    # Fallback to chocolatey
    if (Test-Command choco) {
        if (Install-ChocoPackage "gh") {
            Write-Success "GitHub CLI installed via Chocolatey"
            Add-Success "GitHub CLI"
            Write-Info "Run 'gh auth login' to authenticate"
            return $true
        }
    }
    
    Write-Warning-Custom "Failed to install GitHub CLI"
    Add-Failure "GitHub CLI" "No package manager available"
    return $false
}

function Install-AdditionalTools {
    Write-Step "Installing additional development tools..."
    
    $Tools = @(
        @{ WingetId = "jqlang.jq"; ChocoName = "jq"; Name = "jq (JSON processor)" },
        @{ WingetId = "GnuWin32.Make"; ChocoName = "make"; Name = "Make" },
        @{ WingetId = "vim.vim"; ChocoName = "vim"; Name = "Vim" }
    )
    
    foreach ($tool in $Tools) {
        if (Test-Command winget) {
            Install-WingetPackage $tool.WingetId $tool.Name | Out-Null
        }
        elseif (Test-Command choco) {
            Install-ChocoPackage $tool.ChocoName | Out-Null
        }
    }
    
    Write-Success "Additional tools installation completed"
}

function Setup-PowerShellProfile {
    Write-Step "Configuring PowerShell profile..."
    
    if (-not (Test-Path $PROFILE)) {
        Write-Step "Creating PowerShell profile..."
        New-Item -Path (Split-Path $PROFILE -Parent) -ItemType Directory -Force | Out-Null
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
        Write-Success "PowerShell profile created"
        Add-Success "PowerShell Profile"
    }
    else {
        Write-Success "PowerShell profile already exists"
        Add-Skipped "PowerShell Profile" "Already exists"
    }
    
    # Check if scoop add-on for PowerShell is installed
    Write-Info "PS Profile location: $PROFILE"
    Write-Info "You can enhance your profile by adding aliases and functions"
}

# Main execution
Install-Python
Install-NVMWindows
Install-GitHubCLI
Install-AdditionalTools
Setup-PowerShellProfile
