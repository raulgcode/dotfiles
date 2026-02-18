#!/bin/bash

#===============================================================================
# macOS System Configuration
#===============================================================================

configure_macos() {
    print_step "Applying macOS system preferences..."
    
    # Close System Preferences to prevent overriding
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
    
    #---------------------------------------------------------------------------
    # General UI/UX
    #---------------------------------------------------------------------------
    
    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" " 2>/dev/null || true
    
    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    
    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Save to disk (not iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    
    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
    
    #---------------------------------------------------------------------------
    # Trackpad, Mouse, Keyboard
    #---------------------------------------------------------------------------
    
    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Enable three finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    
    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Set fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    #---------------------------------------------------------------------------
    # Finder
    #---------------------------------------------------------------------------
    
    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    # Use list view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Show the ~/Library folder
    chflags nohidden ~/Library 2>/dev/null || true
    
    # Show the /Volumes folder
    sudo chflags nohidden /Volumes 2>/dev/null || true
    
    #---------------------------------------------------------------------------
    # Dock
    #---------------------------------------------------------------------------
    
    # Set the icon size of Dock items
    defaults write com.apple.dock tilesize -int 48
    
    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true
    
    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    
    # Remove the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0
    
    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0.3
    
    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false
    
    #---------------------------------------------------------------------------
    # Screenshots
    #---------------------------------------------------------------------------
    
    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"
    
    # Save screenshots in PNG format
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    
    #---------------------------------------------------------------------------
    # Safari
    #---------------------------------------------------------------------------
    
    # Enable Safari's debug menu
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true 2>/dev/null || true
    
    # Enable the Develop menu and Web Inspector
    defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null || true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true 2>/dev/null || true
    
    #---------------------------------------------------------------------------
    # Terminal
    #---------------------------------------------------------------------------
    
    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4
    
    # Enable Secure Keyboard Entry in Terminal.app
    defaults write com.apple.terminal SecureKeyboardEntry -bool true
    
    #---------------------------------------------------------------------------
    # Activity Monitor
    #---------------------------------------------------------------------------
    
    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
    
    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5
    
    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0
    
    #---------------------------------------------------------------------------
    # Apply Changes
    #---------------------------------------------------------------------------
    
    # Kill affected applications
    for app in "Finder" "Dock" "SystemUIServer"; do
        killall "${app}" &> /dev/null || true
    done
    
    print_success "macOS preferences configured"
    print_info "Some changes may require a logout/restart to take effect"
    add_success "macOS Preferences"
}

# Run configuration
configure_macos
