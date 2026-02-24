#===============================================================================
# Git Installation and Configuration for Windows
#===============================================================================

function Install-Git {
    Write-Step "Installing Git..."
    
    if (Test-Command git) {
        $version = Get-ProgramVersion "git" "version"
        Write-Success "Git is already installed: $version"
        Add-Skipped "Git" "Already installed"
        return $true
    }
    
    # Try winget first
    if (Test-Command winget) {
        if (Install-WingetPackage "Git.Git" "Git") {
            Write-Success "Git installed via Winget"
            return $true
        }
    }
    
    # Fallback to chocolatey
    if (Test-Command choco) {
        if (Install-ChocoPackage "git") {
            Write-Success "Git installed via Chocolatey"
            return $true
        }
    }
    
    # If no package manager, try downloading from official source
    Write-Warning-Custom "Package managers not available, attempting manual installation..."
    
    try {
        $GitUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
        $TempFile = Join-Path $env:TEMP "git-installer.exe"
        
        if (Get-RemoteFile $GitUrl $TempFile) {
            Write-Step "Running Git installer..."
            Start-Process -FilePath $TempFile -ArgumentList "/SILENT" -NoNewWindow -Wait
            Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
            
            if (Test-Command git) {
                Write-Success "Git installed successfully"
                Add-Success "Git"
                return $true
            }
        }
    }
    catch {
        Write-Error-Custom "Failed to install Git: $_"
        Add-Failure "Git" "Installation failed: $_"
        return $false
    }
    
    return $false
}

function Configure-Git {
    Write-Step "Configuring Git..."
    
    if (-not (Test-Command git)) {
        Write-Error-Custom "Git is not installed, cannot configure"
        return $false
    }
    
    # Get user input for git config
    $emailSet = git config --global user.email
    
    if ([string]::IsNullOrEmpty($emailSet)) {
        Write-Info "Git user configuration not found"
        
        # Try to get from GitHub CLI
        if (Test-Command gh) {
            Write-Step "Attempting to get email from GitHub CLI..."
            $email = gh api user --jq '.email' 2>&1 | Select-String -Pattern "@"
            
            if ($email) {
                Write-Step "Setting Git email: $email"
                git config --global user.email "$email"
                Write-Success "Git email configured"
            }
        }
        else {
            Write-Warning-Custom "GitHub CLI not found, skipping automatic email setup"
            Write-Info "Run: git config --global user.email 'your-email@example.com'"
        }
    }
    else {
        Write-Success "Git already configured with email: $emailSet"
    }
    
    # Standard git configurations
    Write-Step "Applying standard Git configurations..."
    
    try {
        git config --global core.autocrlf true
        git config --global core.ignorecase false
        git config --global init.defaultBranch main
        
        Write-Success "Git configured with Windows-friendly settings"
        Add-Success "Git Configuration"
        return $true
    }
    catch {
        Write-Warning-Custom "Failed to apply some Git configurations"
        return $false
    }
}

# Main execution
Install-Git
Configure-Git
