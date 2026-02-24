#===============================================================================
# VS Code Configuration for Windows
#===============================================================================

function Install-VSCodeExtensions {
    Write-Step "Installing VS Code extensions..."
    
    if (-not (Test-Command code)) {
        Write-Warning-Custom "VS Code is not installed or not in PATH"
        Write-Info "Please install VS Code first and add it to PATH"
        Add-Failure "VS Code Extensions" "VS Code not found in PATH"
        return $false
    }
    
    # Read extensions from config file
    $ExtensionsFile = "$PSScriptRoot\..\configs\vscode\extensions.txt"
    
    if (-not (Test-Path $ExtensionsFile)) {
        Write-Warning-Custom "Extensions file not found at $ExtensionsFile"
        Add-Skipped "VS Code Extensions" "Configuration file not found"
        return $false
    }
    
    Write-Step "Reading extensions from $ExtensionsFile..."
    $extensions = Get-Content $ExtensionsFile | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object { $_.Trim() }
    
    if ($extensions.Count -eq 0) {
        Write-Warning-Custom "No extensions found in configuration"
        return $false
    }
    
    Write-Info "Installing $($extensions.Count) extensions..."
    
    $installed = 0
    $failed = 0
    
    foreach ($extension in $extensions) {
        if ([string]::IsNullOrWhiteSpace($extension)) { continue }
        
        Write-Step "Installing $extension..."
        
        try {
            code --install-extension $extension 2>&1 | Out-Null
            
            # Small delay to avoid race conditions
            Start-Sleep -Milliseconds 500
            
            Write-Success "$extension installed"
            $installed++
        }
        catch {
            Write-Warning-Custom "Failed to install $extension"
            $failed++
        }
    }
    
    Write-Success "VS Code extensions installation completed ($installed/$($extensions.Count) successful)"
    
    if ($failed -gt 0) {
        Add-Failure "VS Code Extensions" "$failed extension(s) failed to install"
    }
    else {
        Add-Success "VS Code Extensions"
    }
    
    return ($failed -eq 0)
}

function Copy-VSCodeSettings {
    Write-Step "Copying VS Code settings..."
    
    if (-not (Test-Command code)) {
        Write-Warning-Custom "VS Code is not installed"
        return $false
    }
    
    # VS Code settings directory
    $SettingsDir = "$env:APPDATA\Code\User"
    $SettingsFile = "$SettingsDir\settings.json"
    $ConfigFile = "$PSScriptRoot\..\configs\vscode\settings.json"
    
    if (-not (Test-Path $ConfigFile)) {
        Write-Warning-Custom "Settings configuration file not found at $ConfigFile"
        Add-Skipped "VS Code Settings" "Configuration file not found"
        return $false
    }
    
    # Create User directory if it doesn't exist
    if (-not (Test-Path $SettingsDir)) {
        Write-Step "Creating VS Code User settings directory..."
        New-Item -Path $SettingsDir -ItemType Directory -Force | Out-Null
    }
    
    try {
        # Back up existing settings
        if (Test-Path $SettingsFile) {
            $BackupFile = "$SettingsFile.backup"
            Copy-Item $SettingsFile $BackupFile -Force
            Write-Info "Backed up existing settings to $BackupFile"
        }
        
        # Copy new settings
        Copy-Item $ConfigFile $SettingsFile -Force
        Write-Success "VS Code settings copied"
        Add-Success "VS Code Settings"
        return $true
    }
    catch {
        Write-Error-Custom "Failed to copy settings: $_"
        Add-Failure "VS Code Settings" "Copy operation failed"
        return $false
    }
}

function Verify-VSCode {
    Write-Step "Verifying VS Code installation..."
    
    if (Test-Command code) {
        $version = & code --version 2>&1 | Select-Object -First 1
        Write-Success "VS Code is installed: $version"
        Add-Success "VS Code"
        return $true
    }
    else {
        Write-Warning-Custom "VS Code is not available in PATH"
        Write-Info "You may need to reinstall VS Code or add it to PATH"
        Write-Info "VS Code path should be in: C:\Users\[YourUsername]\AppData\Local\Programs\Microsoft VS Code"
        return $false
    }
}

# Main execution
Verify-VSCode
Install-VSCodeExtensions
Copy-VSCodeSettings
