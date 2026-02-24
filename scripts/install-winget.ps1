#===============================================================================
# Windows Package Manager Setup (Winget/Chocolatey)
#===============================================================================

function Install-WingetPackageManager {
    Write-Step "Setting up Winget (Windows Package Manager)..."
    
    # Check if Winget is already installed
    if (Test-Command winget) {
        Write-Success "Winget is already installed"
        Add-Skipped "Winget" "Already installed"
        return $true
    }
    
    Write-Step "Installing Winget..."
    
    try {
        # Winget is built into Windows 11 and available for Windows 10
        # Try to install via App Installer from Microsoft Store
        
        # Check Windows version
        $OSVersion = [System.Environment]::OSVersion.Version.Major
        
        if ($OSVersion -ge 11) {
            Write-Info "Windows 11 detected - Winget should be pre-installed"
            Write-Info "Please update Windows to enable Winget"
        }
        elseif ($OSVersion -eq 10) {
            Write-Step "Attempting to install Winget on Windows 10..."
            
            # Try via Microsoft Store
            Write-Info "Installing App Installer from Microsoft Store..."
            $StoreApp = Get-AppxPackage "Microsoft.DesktopAppInstaller"
            
            if (-not $StoreApp) {
                # Fallback: Install via GitHub release
                Write-Info "Downloading Winget from GitHub..."
                $WingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
                $TempFile = Join-Path $env:TEMP "winget-installer.msixbundle"
                
                if (Get-RemoteFile $WingetUrl $TempFile) {
                    Add-AppxPackage -Path $TempFile -ErrorAction SilentlyContinue
                    Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
                    Write-Success "Winget installed"
                    Add-Success "Winget"
                    return $true
                }
            }
            else {
                Write-Success "Winget (App Installer) is installed"
                Add-Success "Winget"
                return $true
            }
        }
        
        return $true
    }
    catch {
        Write-Error-Custom "Failed to setup Winget: $_"
        Add-Failure "Winget" "Setup failed: $_"
        return $false
    }
}

function Install-Chocolatey {
    Write-Step "Setting up Chocolatey as fallback package manager..."
    
    # Check if Chocolatey is already installed
    if (Test-Command choco) {
        Write-Success "Chocolatey is already installed"
        Add-Skipped "Chocolatey" "Already installed"
        return $true
    }
    
    if (-not (Test-Admin)) {
        Write-Warning-Custom "Chocolatey installation requires administrator privileges"
        return $false
    }
    
    Write-Step "Installing Chocolatey..."
    
    try {
        $ChocoInstallScript = @"
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
"@
        
        Invoke-Expression $ChocoInstallScript -ErrorAction Stop 2>&1 | Out-Null
        
        if (Test-Command choco) {
            Write-Success "Chocolatey installed successfully"
            Add-Success "Chocolatey"
            return $true
        }
        else {
            Write-Error-Custom "Chocolatey installation appears to have failed"
            Add-Failure "Chocolatey" "Installation verification failed"
            return $false
        }
    }
    catch {
        Write-Error-Custom "Failed to install Chocolatey: $_"
        Add-Failure "Chocolatey" "Installation failed: $_"
        return $false
    }
}

function Test-PackageManager {
    if (Test-Command winget) {
        Write-Success "Winget is available as package manager"
        return "winget"
    }
    elseif (Test-Command choco) {
        Write-Success "Chocolatey is available as package manager"
        return "choco"
    }
    else {
        Write-Warning-Custom "No package manager found"
        return $null
    }
}

# Main installation
Write-Step "Checking package managers..."

# Try winget first (modern/preferred)
Install-WingetPackageManager

# Also setup chocolatey as fallback
Install-Chocolatey

# Determine which package manager is available
$PackageManager = Test-PackageManager

if ($PackageManager) {
    Write-Success "Package manager setup completed. Using: $PackageManager"
    Add-Success "Package Manager"
}
else {
    Write-Warning-Custom "No package manager is available. Some installations may fail."
    Write-Info "Please install Winget or Chocolatey manually"
}
