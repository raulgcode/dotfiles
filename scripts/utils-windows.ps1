#===============================================================================
# Windows Utility Functions
# Shared helper functions for all Windows installation scripts
#===============================================================================

# Color output helper
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Blue
}

function Write-Step {
    param([string]$Message)
    Write-Host "➜ $Message" -ForegroundColor Cyan
}

function Show-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Magenta
    Write-Host "  $Title" -ForegroundColor Magenta
    Write-Host ("=" * 60) -ForegroundColor Magenta
    Write-Host ""
}

# Installation tracking
$script:SuccessfulInstalls = @()
$script:FailedInstalls = @()
$script:SkippedInstalls = @()
$script:UpgradedInstalls = @()

function Add-Success {
    param([string]$Name)
    $script:SuccessfulInstalls += $Name
}

function Add-Failure {
    param([string]$Name, [string]$Reason = "Unknown error")
    $script:FailedInstalls += "$Name : $Reason"
}

function Add-Skipped {
    param([string]$Name, [string]$Reason = "Already installed")
    $script:SkippedInstalls += "$Name : $Reason"
}

function Add-Upgraded {
    param([string]$Name, [string]$OldVersion, [string]$NewVersion)
    $script:UpgradedInstalls += "$Name : $OldVersion → $NewVersion"
}

function Show-InstallationReport {
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Magenta
    Write-Host "  Installation Report" -ForegroundColor Magenta
    Write-Host ("=" * 60) -ForegroundColor Magenta
    Write-Host ""
    
    if ($script:SuccessfulInstalls.Count -gt 0) {
        Write-Host "✓ Successfully Installed ($($script:SuccessfulInstalls.Count)):" -ForegroundColor Green
        foreach ($item in $script:SuccessfulInstalls) {
            Write-Host "  • $item" -ForegroundColor Green
        }
        Write-Host ""
    }
    
    if ($script:UpgradedInstalls.Count -gt 0) {
        Write-Host "↑ Upgraded ($($script:UpgradedInstalls.Count)):" -ForegroundColor Cyan
        foreach ($item in $script:UpgradedInstalls) {
            Write-Host "  • $item" -ForegroundColor Cyan
        }
        Write-Host ""
    }
    
    if ($script:SkippedInstalls.Count -gt 0) {
        Write-Host "⊘ Skipped ($($script:SkippedInstalls.Count)):" -ForegroundColor Yellow
        foreach ($item in $script:SkippedInstalls) {
            Write-Host "  • $item" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    if ($script:FailedInstalls.Count -gt 0) {
        Write-Host "✗ Failed ($($script:FailedInstalls.Count)):" -ForegroundColor Red
        foreach ($item in $script:FailedInstalls) {
            Write-Host "  • $item" -ForegroundColor Red
        }
        Write-Host ""
    }
    else {
        Write-Host "✓ All installations completed without errors!" -ForegroundColor Green
    }
    Write-Host ""
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check if running with admin privileges
function Test-Admin {
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Install or check for chocolatey package
function Install-ChocoPackage {
    param([string]$PackageName)
    
    if (choco list --local-only | Select-String -Pattern "^$PackageName\s" -Quiet) {
        Write-Success "$PackageName is already installed"
        Add-Skipped $PackageName "Already installed"
        return $true
    }
    
    Write-Step "Installing $PackageName..."
    try {
        choco install $PackageName -y --no-progress 2>&1 | Out-Null
        Write-Success "$PackageName installed"
        Add-Success $PackageName
        return $true
    }
    catch {
        Write-Error-Custom "Failed to install $PackageName"
        Add-Failure $PackageName "Installation failed: $_"
        return $false
    }
}

# Install or check for winget package
function Install-WingetPackage {
    param([string]$PackageId, [string]$DisplayName = $PackageId)
    
    Write-Step "Checking for $DisplayName..."
    
    # Check if already installed
    $installed = winget list --id $PackageId -e 2>&1 | Select-String -Pattern $PackageId -Quiet
    
    if ($installed) {
        Write-Success "$DisplayName is already installed"
        Add-Skipped $DisplayName "Already installed"
        return $true
    }
    
    Write-Step "Installing $DisplayName..."
    try {
        winget install --id=$PackageId --exact --silent 2>&1 | Out-Null
        
        # Verify installation
        $installed = winget list --id $PackageId -e 2>&1 | Select-String -Pattern $PackageId -Quiet
        if ($installed) {
            Write-Success "$DisplayName installed"
            Add-Success $DisplayName
            return $true
        }
        else {
            Write-Warning-Custom "$DisplayName installation completed but unable to verify"
            Add-Skipped $DisplayName "Installation questionable"
            return $false
        }
    }
    catch {
        Write-Error-Custom "Failed to install $DisplayName"
        Add-Failure $DisplayName "Installation failed: $_"
        return $false
    }
}

# Safe execution wrapper
function Invoke-SafeCommand {
    param([string]$Description, [scriptblock]$Command)
    
    Write-Step "$Description..."
    try {
        & $Command
        Write-Success "$Description completed"
        return $true
    }
    catch {
        Write-Error-Custom "$Description failed`n  Error: $_"
        Add-Failure $Description "Command failed: $_"
        return $false
    }
}

# Download file with error handling
function Get-RemoteFile {
    param([string]$Uri, [string]$OutFile)
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
        return $true
    }
    catch {
        Write-Error-Custom "Failed to download $Uri"
        return $false
    }
}

# Expand archive
function Expand-Archive-Safe {
    param([string]$Path, [string]$DestinationPath)
    
    try {
        if (Test-Path $DestinationPath) {
            Remove-Item $DestinationPath -Recurse -Force
        }
        Expand-Archive -Path $Path -DestinationPath $DestinationPath -Force
        return $true
    }
    catch {
        Write-Error-Custom "Failed to expand archive: $_"
        return $false
    }
}

# Check if program is installed (by checking PATH)
function Test-ProgramInstalled {
    param([string]$ProgramName)
    
    return (Test-Command $ProgramName) -or (Get-Command $ProgramName -ErrorAction SilentlyContinue)
}

# Get installed version of program
function Get-ProgramVersion {
    param([string]$ProgramName, [string]$VersionFlag = "--version")
    
    try {
        $version = & $ProgramName $VersionFlag 2>&1 | Select-Object -First 1
        return $version -replace "^[^\d]*", "" # Remove leading non-numeric chars
    }
    catch {
        return "unknown"
    }
}
