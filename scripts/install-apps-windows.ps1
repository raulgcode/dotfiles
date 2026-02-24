#===============================================================================
# Application Installation for Windows
#===============================================================================

function Install-Applications {
    Write-Step "Installing core applications..."
    
    # Determine which package manager to use
    $PackageManager = if (Test-Command winget) { "winget" } elseif (Test-Command choco) { "choco" } else { $null }
    
    if (-not $PackageManager) {
        Write-Error-Custom "No package manager available (Winget or Chocolatey)"
        return $false
    }
    
    # Core applications
    $CoreApps = @(
        @{ Id = "Google.Chrome"; Name = "Google Chrome"; Manager = "winget" },
        @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code"; Manager = "winget" },
        @{ Id = "Docker.DockerDesktop"; Name = "Docker Desktop"; Manager = "winget" },
        @{ Id = "Postman.Postman"; Name = "Postman"; Manager = "winget" }
    )
    
    # Fallback for Chocolatey
    $ChocoApps = @(
        @{ Name = "googlechrome"; DisplayName = "Google Chrome" },
        @{ Name = "vscode"; DisplayName = "Visual Studio Code" },
        @{ Name = "docker-desktop"; DisplayName = "Docker Desktop" },
        @{ Name = "postman"; DisplayName = "Postman" }
    )
    
    foreach ($app in $CoreApps) {
        if ($PackageManager -eq "winget") {
            Install-WingetPackage $app.Id $app.Name
        }
    }
    
    # If using chocolatey, use different package names
    if ($PackageManager -eq "choco") {
        foreach ($app in $ChocoApps) {
            Install-ChocoPackage $app.Name
        }
    }
    
    Write-Success "Core application installation completed"
}

function Install-OptionalApplications {
    Write-Step "Installing optional applications..."
    
    $PackageManager = if (Test-Command winget) { "winget" } elseif (Test-Command choco) { "choco" } else { $null }
    
    if (-not $PackageManager) {
        Write-Warning-Custom "No package manager available for optional apps"
        return
    }
    
    # Optional applications (uncomment as needed)
    $OptionalApps = @(
        # Communication
        @{ Id = "Discord.Discord"; Name = "Discord"; Enabled = $false },
        @{ Id = "OpenWhisperSystems.Signal"; Name = "Signal"; Enabled = $false },
        
        # Development
        @{ Id = "JetBrains.IntelliJIDEA.Community"; Name = "IntelliJ IDEA Community"; Enabled = $false },
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"; Enabled = $true },
        @{ Id = "warps.warp"; Name = "Warp Terminal"; Enabled = $false },
        @{ Id = "Google.Antigravity"; Name = "Google Antigravity"; Enabled = $false },
        @{ Id = "GNU.Emacs"; Name = "Emacs"; Enabled = $false },
        
        # Productivity
        @{ Id = "Obsidian.Obsidian"; Name = "Obsidian"; Enabled = $false },
        @{ Id = "Notion.Notion"; Name = "Notion"; Enabled = $false },
        
        # Browsers
        @{ Id = "Mozilla.Firefox"; Name = "Firefox"; Enabled = $false },
        @{ Id = "BraveSoftware.BraveBrowser"; Name = "Brave Browser"; Enabled = $false },
        
        # Utilities
        @{ Id = "7zip.7zip"; Name = "7-Zip"; Enabled = $true },
        @{ Id = "RarLab.WinRAR"; Name = "WinRAR"; Enabled = $false }
    )
    
    foreach ($app in $OptionalApps) {
        if ($app.Enabled) {
            if ($PackageManager -eq "winget") {
                Install-WingetPackage $app.Id $app.Name
            }
        }
    }
    
    Write-Success "Optional application installation completed"
}

function Set-DefaultBrowser {
    Write-Step "Setting Chrome as default browser..."
    
    # Check if Chrome is installed
    $ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (-not (Test-Path $ChromePath)) {
        $ChromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    }
    
    if (Test-Path $ChromePath) {
        try {
            # This requires elevated privileges and may not work in all scenarios
            $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice"
            
            Write-Info "Setting Chrome as default browser (manual steps may be required)"
            Write-Info "You can also manually set it in Settings > Apps > Default apps"
            
            Write-Success "Chrome is installed and ready to be set as default"
            Add-Success "Browser Setup"
        }
        catch {
            Write-Warning-Custom "Could not automatically set Chrome as default"
            Write-Info "Please set it manually in Windows Settings > Default apps"
        }
    }
    else {
        Write-Warning-Custom "Google Chrome not found"
    }
}

function Start-Docker {
    Write-Step "Starting Docker Desktop..."
    
    $DockerPath = "C:\Program Files\Docker\Docker\Docker.exe"
    
    if (Test-Path $DockerPath) {
        try {
            Start-Process $DockerPath -WindowStyle Minimized
            Write-Success "Docker Desktop started"
            Write-Info "Please complete Docker Desktop setup when prompted"
            Add-Success "Docker Desktop"
        }
        catch {
            Write-Warning-Custom "Could not start Docker Desktop"
            Write-Info "Please start it manually from Start Menu"
        }
    }
    else {
        Write-Warning-Custom "Docker Desktop not found"
    }
}

# Main execution
Install-Applications
Install-OptionalApplications
Set-DefaultBrowser
Start-Docker
