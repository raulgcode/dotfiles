#===============================================================================
# Windows System Configuration
#===============================================================================

function Enable-DeveloperMode {
    Write-Step "Enabling Windows Developer Mode..."
    
    if (-not (Test-Admin)) {
        Write-Warning-Custom "Developer Mode setup requires administrator privileges"
        return $false
    }
    
    try {
        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        $RegKey = "AllowDevelopmentWithoutDevLicense"
        
        # Check if already enabled
        if ((Get-ItemProperty -Path $RegPath -Name $RegKey -ErrorAction SilentlyContinue).$RegKey -eq 1) {
            Write-Success "Developer Mode is already enabled"
            Add-Skipped "Developer Mode" "Already enabled"
            return $true
        }
        
        # Enable Developer Mode
        Set-ItemProperty -Path $RegPath -Name $RegKey -Value 1 -ErrorAction SilentlyContinue
        Write-Success "Developer Mode enabled"
        Add-Success "Developer Mode"
        return $true
    }
    catch {
        Write-Warning-Custom "Could not enable Developer Mode: $_"
        return $false
    }
}

function Enable-LongPathSupport {
    Write-Step "Enabling Long Path support..."
    
    if (-not (Test-Admin)) {
        Write-Warning-Custom "Long Path support requires administrator privileges"
        return $false
    }
    
    try {
        $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
        $RegKey = "LongPathsEnabled"
        
        # Check if already enabled
        if ((Get-ItemProperty -Path $RegPath -Name $RegKey -ErrorAction SilentlyContinue).$RegKey -eq 1) {
            Write-Success "Long Path support is already enabled"
            Add-Skipped "Long Path Support" "Already enabled"
            return $true
        }
        
        # Enable Long Path support
        Set-ItemProperty -Path $RegPath -Name $RegKey -Value 1 -ErrorAction SilentlyContinue
        Write-Success "Long Path support enabled"
        Add-Success "Long Path Support"
        return $true
    }
    catch {
        Write-Warning-Custom "Could not enable Long Path support: $_"
        return $false
    }
}

function Configure-FileExplorer {
    Write-Step "Configuring File Explorer..."
    
    try {
        # Show file extensions
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force
        
        # Show hidden files
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force
        
        # Show full path in title bar
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value 1 -Force
        
        Write-Success "File Explorer configured (show extensions, hidden files, full path)"
        Add-Success "File Explorer Settings"
        return $true
    }
    catch {
        Write-Warning-Custom "Could not configure File Explorer: $_"
        return $false
    }
}

function Enable-VirtualizationFeatures {
    Write-Step "Checking virtualization features..."
    
    if (-not (Test-Admin)) {
        Write-Warning-Custom "Virtualization features require administrator privileges"
        Write-Info "Please enable Hyper-V manually for Docker and other virtualization"
        return $false
    }
    
    try {
        # Check if Hyper-V is available
        $HyperV = Get-WindowsOptionalFeature -FeatureName "Hyper-V" -Online -ErrorAction SilentlyContinue
        
        if ($HyperV.State -eq "Enabled") {
            Write-Success "Hyper-V is already enabled"
            Add-Skipped "Hyper-V" "Already enabled"
        }
        else {
            Write-Warning-Custom "Hyper-V is not enabled"
            Write-Info "This is required for Docker Desktop"
            Write-Info "You can enable it with PowerShell:"
            Write-Info "  Enable-WindowsOptionalFeature -FeatureName Hyper-V -All -Online"
        }
        
        return $HyperV.State -eq "Enabled"
    }
    catch {
        Write-Warning-Custom "Could not check Hyper-V status: $_"
        return $false
    }
}

function Optimize-VisualPerformance {
    Write-Step "Applying performance optimizations..."
    
    try {
        # Disable animations for better performance
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x01,0x80,0x10,0x00,0x00,0x00)) -Force
        
        Write-Success "Performance settings applied"
        Add-Success "Performance Optimization"
        return $true
    }
    catch {
        Write-Warning-Custom "Could not apply performance settings: $_"
        return $false
    }
}

function Configure-TaskBar {
    Write-Step "Configuring Windows Taskbar..."
    
    try {
        # This is mainly informational - full taskbar customization would require more complex logic
        Write-Info "Taskbar configuration would be done here (currently has limitations)"
        Write-Info "You can manually customize taskbar by right-clicking and selecting 'Taskbar settings'"
        
        Add-Skipped "Taskbar" "Manual configuration recommended"
        return $true
    }
    catch {
        Write-Warning-Custom "Could not configure taskbar: $_"
        return $false
    }
}

# Main execution
Write-Info "Applying Windows system optimizations..."
Write-Info "Some settings require administrator privileges"
Write-Host ""

Enable-DeveloperMode
Enable-LongPathSupport
Configure-FileExplorer
Enable-VirtualizationFeatures
Optimize-VisualPerformance
Configure-TaskBar

Write-Info ""
Write-Info "Windows configuration completed"
