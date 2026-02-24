#===============================================================================
#
#   Windows Development Environment Setup
#   Author: Raul Gonzalez
#   Description: Automated Windows development environment setup
#
#   Usage (from PowerShell):
#     powershell -ExecutionPolicy Bypass -File setup.ps1
#
#   Or download and run:
#     iwr -useb https://raw.githubusercontent.com/raulgcode/dotfiles/main/setup.ps1 | iex
#
#===============================================================================

param(
    [switch]$SkipPackageManager = $false,
    [switch]$SkipGit = $false,
    [switch]$SkipVSCode = $false,
    [switch]$SkipDevTools = $false,
    [switch]$SkipWindowsConfig = $false
)

# Set error action preference to continue on error
$ErrorActionPreference = "Continue"

# Get script directory
$ScriptDir = Split-Path -Parent (Convert-Path $MyInvocation.MyCommand.Path)

# If running from curl, clone the repository
if (-not (Test-Path "$ScriptDir\scripts")) {
    Write-Host "Fetching dotfiles from GitHub..." -ForegroundColor Cyan
    $TempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    
    try {
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git clone --depth 1 https://github.com/raulgcode/dotfiles.git "$TempDir" 2>&1
        }
        else {
            # Fallback to curl/expand-archive
            $zipFile = "$TempDir\dotfiles.zip"
            Invoke-WebRequest -Uri "https://github.com/raulgcode/dotfiles/archive/refs/heads/main.zip" -OutFile $zipFile
            Expand-Archive -Path $zipFile -DestinationPath $TempDir -Force
            Move-Item "$TempDir\dotfiles-main\*" "$TempDir\" -Force
            Remove-Item "$TempDir\dotfiles-main" -Force
        }
        $ScriptDir = $TempDir
    }
    catch {
        Write-Host "Failed to fetch repository: $_" -ForegroundColor Red
        exit 1
    }
}

# Source utility functions
. "$ScriptDir\scripts\utils-windows.ps1"

#===============================================================================
# Main Setup
#===============================================================================

function Start-Setup {
    Show-Header "Windows Development Environment Setup"
    
    Write-Host "This script will install and configure:" -ForegroundColor Blue
    Write-Host "  • Package manager (Winget or Chocolatey)"
    Write-Host "  • Applications (Chrome, VS Code, Docker, Postman)"
    Write-Host "  • Development tools (Git, Python, Node.js)"
    Write-Host "  • VS Code extensions"
    Write-Host "  • Windows settings optimization"
    Write-Host ""
    
    # Check if running with admin privileges
    if (-not (Test-Admin)) {
        Write-Host "⚠ This script should ideally run with administrator privileges." -ForegroundColor Yellow
        Write-Host "Some installations may fail without admin rights." -ForegroundColor Yellow
        Write-Host ""
        $Continue = Read-Host "Continue anyway? (y/n)"
        if ($Continue -ne "y") {
            Write-Host "Setup cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
    else {
        Write-Host "✓ Running with administrator privileges" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # Windows settings first
    if (-not $SkipWindowsConfig) {
        Show-Header "Applying Windows Settings"
        . "$ScriptDir\scripts\configure-windows.ps1"
    }
    else {
        Write-Host "Skipping Windows configuration (as requested)" -ForegroundColor Blue
    }
    
    # Install package manager
    if (-not $SkipPackageManager) {
        Show-Header "Setting up Package Manager"
        . "$ScriptDir\scripts\install-winget.ps1"
    }
    else {
        Write-Host "Skipping package manager setup (as requested)" -ForegroundColor Blue
    }
    
    # Install Git
    if (-not $SkipGit) {
        Show-Header "Installing Git"
        . "$ScriptDir\scripts\install-git-windows.ps1"
    }
    else {
        Write-Host "Skipping Git installation (as requested)" -ForegroundColor Blue
    }
    
    # Install applications
    Show-Header "Installing Applications"
    . "$ScriptDir\scripts\install-apps-windows.ps1"
    
    # Install development tools
    if (-not $SkipDevTools) {
        Show-Header "Installing Development Tools"
        . "$ScriptDir\scripts\install-dev-tools-windows.ps1"
    }
    else {
        Write-Host "Skipping development tools (as requested)" -ForegroundColor Blue
    }
    
    # Configure VS Code
    if (-not $SkipVSCode) {
        Show-Header "Configuring VS Code"
        . "$ScriptDir\scripts\install-vscode-windows.ps1"
    }
    else {
        Write-Host "Skipping VS Code configuration (as requested)" -ForegroundColor Blue
    }
    
    # Final summary
    Show-Header "Setup Complete!"
    
    Write-Host "Your Windows development environment is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart your terminal or run: `$PROFILE" -ForegroundColor Gray
    Write-Host "  2. Open VS Code and sign in to sync settings" -ForegroundColor Gray
    Write-Host "  3. Open Docker Desktop and complete setup" -ForegroundColor Gray
    Write-Host "  4. Run 'git config --global user.email' to configure Git" -ForegroundColor Gray
    Write-Host ""
    
    Show-InstallationReport
    
    Write-Host "Enjoy your new development setup! 🚀" -ForegroundColor Green
}

# Run main function
Start-Setup
