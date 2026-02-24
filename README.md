# Development Environment Setup

Automated setup scripts for configuring a new machine with essential development tools, applications, and configurations. Supports both **macOS** and **Windows**.

## Platform-Specific Quick Start

### macOS

Run this single command to set up your entire development environment:

```bash
curl -fsSL https://raw.githubusercontent.com/raulgcode/dotfiles/main/setup.sh | bash -s --
```

Or clone and run locally:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

### Windows

Run this single command (in PowerShell) to set up your entire development environment:

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/raulgcode/dotfiles/main/setup.ps1 | iex"
```

Or clone and run locally:

```powershell
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
.\setup.ps1
```

**Note**: Windows setup requires **PowerShell 5.0+** (built-in on Windows 10/11). For best results, run PowerShell as Administrator.

## What Gets Installed

### Applications

| Application | macOS | Windows |
|-------------|-------|---------|
| Google Chrome | ✓ | ✓ |
| Visual Studio Code | ✓ | ✓ |
| Docker Desktop | ✓ | ✓ |
| Postman | ✓ | ✓ |
| Discord | ✓ | ✓ |
| Firefox | ✓ | ✓ |
| Windows Terminal | ✗ | ✓ |
| 7-Zip | ✗ | ✓ |

### Development Tools

| Tool | macOS | Windows |
|------|-------|---------|
| Git | ✓ | ✓ |
| Python 3.12 | ✓ | ✓ |
| Node.js (via nvm) | ✓ *nvm* | ✓ *nvm-windows* |
| GitHub CLI | ✓ | ✓ |
| jq | ✓ | ✓ |
| Package Manager | Homebrew | Winget/Chocolatey |

### macOS-Specific

| Tool | Description |
|------|-------------|
| Xcode Command Line Tools | Apple developer tools |
| nvm | Node Version Manager |
| zsh-autosuggestions | Fish-like autosuggestions for zsh |
| zsh-syntax-highlighting | Syntax highlighting for zsh |

### Windows-Specific

| Tool | Description |
|------|-------------|
| Winget | Windows Package Manager (modern) |
| Chocolatey | Windows Package Manager (fallback) |
| Windows Terminal | Modern terminal application |
| Long Path Support | Enable paths longer than 260 characters |
| Developer Mode | Enable development features |

### VS Code Extensions

The setup includes 40+ carefully selected extensions:

- **AI & Copilot**: GitHub Copilot, Claude
- **Code Quality**: Prettier, ESLint, Stylelint
- **Git**: GitLens, GitHub Actions, Git Graph
- **JavaScript/TypeScript**: TypeScript, React snippets
- **Testing**: Vitest, Playwright
- **CSS**: Tailwind CSS, PostCSS, Styled Components
- **Database**: Prisma, PostgreSQL
- **Remote Development**: SSH, Containers
- **DevOps**: Docker, Kubernetes, YAML
- **Python**: Python, Pylance

See [configs/vscode/extensions.txt](configs/vscode/extensions.txt) for the complete list.

## Project Structure

```
dotfiles/
├── README.md                         # This file
├── setup.sh                          # macOS main entry point
├── setup.ps1                         # Windows main entry point
├── configs/
│   ├── Brewfile                      # Homebrew bundle (macOS)
│   └── vscode/
│       ├── extensions.txt            # VS Code extensions (cross-platform)
│       └── settings.json             # VS Code settings (cross-platform)
└── scripts/
    ├── macOS Scripts (Bash):
    │   ├── utils.sh                  # Shared helper functions
    │   ├── install-xcode.sh          # Xcode CLI tools
    │   ├── install-brew.sh           # Homebrew
    │   ├── install-apps.sh           # GUI applications
    │   ├── install-dev-tools.sh      # Development tools
    │   ├── install-vscode.sh         # VS Code configuration
    │   ├── install-zsh-plugins.sh    # ZSH plugins
    │   └── configure-macos.sh        # macOS preferences
    │
    └── Windows Scripts (PowerShell):
        ├── utils-windows.ps1         # Shared helper functions
        ├── install-winget.ps1        # Winget/Chocolatey setup
        ├── install-git-windows.ps1   # Git installation
        ├── install-apps-windows.ps1  # GUI applications
        ├── install-dev-tools-windows.ps1  # Development tools
        ├── install-vscode-windows.ps1    # VS Code configuration
        └── configure-windows.ps1     # Windows settings
```

## Features

### Smart Installation

- **Version Checking**: Automatically detects if software is already installed and up to date
- **Automatic Upgrades**: Upgrades outdated packages to the latest version
- **Skip Up-to-Date**: Skips packages that are already at the latest version
- **Continue on Failure**: If an installation fails, the script continues with the next item
- **Installation Report**: Generates a detailed report at the end showing:
  - ✓ Successfully installed items
  - ↑ Upgraded items (with version changes)
  - ⊘ Skipped items (already up to date)
  - ✗ Failed items (with error details)

### Cross-Platform

- **One Configuration**: VS Code extensions and settings are synced across platforms
- **Platform Detection**: Scripts automatically detect the operating system and use the appropriate tools
- **Consistent Environments**: Same development tools on both macOS and Windows

### Windows-Specific Features

- **Package Manager Fallback**: Uses Winget (modern) with Chocolatey as fallback
- **System Optimization**: Automatically enables:
  - Developer Mode
  - Long Path Support (for npm/Python packages)
  - Hyper-V detection for Docker Desktop
  - File Explorer enhancements
- **PowerShell Friendly**: Uses PowerShell 5.0+ for reliability
- **Admin Detection**: Prompts for administrator rights when needed

### macOS-Specific Features

- **Xcode Integration**: Automatically installs Xcode Command Line Tools
- **zsh Configuration**: Installs and configures zsh plugins with custom functions
- **Default Browser**: Sets Chrome as default browser
- **System Preferences**: Applies macOS-specific optimizations

### Example Report Output

```
============================================================
  Installation Report
============================================================

✓ Successfully Installed (5):
  • google-chrome
  • visual-studio-code
  • Node.js LTS
  • VS Code Extensions (15 new)
  • ZSH Configuration

↑ Upgraded (2):
  • git: 2.43.0 → 2.44.0
  • python@3.12: 3.12.1 → 3.12.2

⊘ Skipped (8):
  • Homebrew: Already installed
  • docker: Up to date (4.27.0)
  • jq: Up to date (1.7.1)

✗ Failed (1):
  • some-package: Installation failed

All installations completed!
```

## Customization

### Adding New Applications

1. **Via Brewfile** (recommended):
   Edit `configs/Brewfile` and add:
   ```ruby
   cask "application-name"   # For GUI apps
   brew "formula-name"       # For CLI tools
   ```

2. **Via install script**:
   Edit `scripts/install-apps.sh` and add:
   ```bash
   install_cask "application-name"
   ```

### Adding VS Code Extensions

Edit `configs/vscode/extensions.txt` and add the extension ID:
```
publisher.extension-name
```

Find extension IDs in the VS Code marketplace URL or by right-clicking an extension in VS Code.

### Adding ZSH Configuration

Edit `scripts/install-zsh-plugins.sh` or create a new file in `configs/zsh/`.

### Adding macOS Preferences

Edit `scripts/configure-macos.sh` to add new `defaults write` commands.

## Running Individual Scripts

### macOS

You can run specific scripts independently:

```bash
# Install only Homebrew
./scripts/install-brew.sh

# Install only applications
./scripts/install-apps.sh

# Configure VS Code
./scripts/install-vscode.sh

# Configure ZSH
./scripts/install-zsh-plugins.sh

# Configure macOS
./scripts/configure-macos.sh
```

### Windows

You can run specific scripts independently:

```powershell
# Install only Winget/Chocolatey
.\scripts\install-winget.ps1

# Install only applications
.\scripts\install-apps-windows.ps1

# Configure VS Code
.\scripts\install-vscode-windows.ps1

# Configure Windows settings
.\scripts\configure-windows.ps1

# Install development tools
.\scripts\install-dev-tools-windows.ps1
```

You can also skip specific steps when running the main setup:

```powershell
# Skip Windows configuration
.\setup.ps1 -SkipWindowsConfig

# Skip package manager setup
.\setup.ps1 -SkipPackageManager

# Skip multiple items
.\setup.ps1 -SkipVSCode -SkipDevTools
```

## Post-Installation Steps

### macOS

After the setup completes:

1. **Restart Terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Authenticate GitHub CLI**:
   ```bash
   gh auth login
   ```

3. **Complete Docker Setup**:
   Open Docker Desktop and follow the setup wizard.

4. **Configure VS Code Settings Sync**:
   Sign in with your GitHub account to sync settings.

5. **Install Fonts** (optional):
   ```bash
   brew install --cask font-jetbrains-mono font-fira-code
   ```

### Windows

After the setup completes:

1. **Verify Installation**:
   - Check that all applications appear in Start Menu
   - Open PowerShell and test: `python --version`, `node --version`, `git --version`

2. **Authenticate GitHub CLI**:
   ```powershell
   gh auth login
   ```

3. **Manage Node.js Versions** (nvm-windows):
   ```powershell
   # List available versions
   nvm list available
   
   # Install a specific version
   nvm install 20.10.0
   
   # Use a version
   nvm use 20.10.0
   
   # View currently selected version
   nvm current
   ```

4. **Complete Docker Setup**:
   - Open Docker Desktop from Start Menu
   - Follow the setup wizard
   - Ensure Hyper-V is enabled (settings will prompt if needed)

5. **Configure VS Code Settings Sync**:
   - Sign in with your GitHub account to sync settings
   - Install fonts from: Settings > Text Editor > Font > Font Family

6. **Configure Git** (if not auto-detected):
   ```powershell
   git config --global user.email "your-email@example.com"
   git config --global user.name "Your Name"
   ```

7. **Enable Windows Features** (if needed):
   ```powershell
   # Enable Hyper-V for Docker
   Enable-WindowsOptionalFeature -FeatureName Hyper-V -All -Online
   # Restart computer after this
   ```

## Using Brewfile Directly

You can also use Homebrew Bundle directly:

```bash
# Install everything from Brewfile
brew bundle --file=configs/Brewfile

# Check what would be installed
brew bundle check --file=configs/Brewfile

# List what's in the Brewfile
brew bundle list --file=configs/Brewfile
```

## One-line Installer (curl)

For a quick, non-interactive install from the published repository, run the one-line installer:

```bash
curl -fsSL https://raw.githubusercontent.com/raulgcode/dotfiles/main/setup.sh | bash -s --
```

Notes:
- You can override the repository used by the installer by setting `DOTFILES_REPO`:

```bash
DOTFILES_REPO="https://github.com/yourname/dotfiles.git" \
   curl -fsSL https://raw.githubusercontent.com/raulgcode/dotfiles/main/setup.sh | bash -s --
```
- The installer attempts a `git` clone when available and falls back to downloading a tarball of the `main` branch when `git` is not present.
- The script detects non-interactive shells and proceeds without prompting; if you run it in an interactive terminal you'll see a confirmation prompt before continuing.
- For safety, review `setup.sh` before piping it into `bash` if you have concerns.


## Troubleshooting

### macOS Issues

#### Homebrew Issues

```bash
# Update Homebrew
brew update

# Fix any issues
brew doctor

# Clean up old versions
brew cleanup
```

#### VS Code CLI Not Working

```bash
# Add to PATH manually
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
```

#### nvm Not Found

```bash
# Reload shell configuration
source ~/.zshrc

# Or manually load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

#### Permission Errors

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/Homebrew
sudo chown -R $(whoami) /usr/local/var/homebrew
```

### Windows Issues

#### PowerShell Execution Policy

If you get an error about script execution, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Package Manager Not Found

If Winget is not available:
1. Update Windows 10/11 to the latest version
2. Install Microsoft Store App Installer from Microsoft Store
3. Or run setup with Chocolatey as fallback (automatic)

#### VS Code Extensions Not Installing

1. Ensure VS Code is installed and in PATH:
   ```powershell
   code --version
   ```

2. If not found, add VS Code to PATH:
   ```powershell
   $VSCodePath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code\bin"
   [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$VSCodePath", "User")
   ```

3. Restart PowerShell and try again

#### Git Command Not Found

Ensure Git is in PATH:
```powershell
git --version
```

If not found, add to PATH manually or reinstall Git with "Add to PATH" option selected.

#### Admin Rights Required

The setup requires administrator privileges. Run PowerShell as Administrator:
1. Right-click PowerShell or Windows Terminal
2. Select "Run as administrator"
3. Then run the setup script

#### Docker Desktop Not Starting

Docker requires Hyper-V on Windows Home Edition. Enable it:
```powershell
Enable-WindowsOptionalFeature -FeatureName Hyper-V -All -Online
# Restart your computer after
```

#### nvm-windows Not Found After Installation

After installing nvm-windows, you may need to restart PowerShell or your computer:
```powershell
# Close and reopen PowerShell, then verify:
nvm --version

# If still not found, add to PATH manually:
$NVMPath = "$env:PROGRAMFILES\nvm"
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$NVMPath", "User")
```

Then install Node.js LTS:
```powershell
nvm install lts
nvm use lts
node --version  # Verify installation
```

## Backup & Restore

### Creating a Backup

```bash
# Export installed brews/casks
brew bundle dump --file=~/Brewfile.backup

# Export VS Code extensions
code --list-extensions > ~/vscode-extensions.backup.txt
```

### Restoring from Backup

```bash
# Install from Brewfile
brew bundle --file=~/Brewfile.backup

# Install VS Code extensions
cat ~/vscode-extensions.backup.txt | xargs -L 1 code --install-extension
```

## Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - Feel free to use and modify as needed.

## Credits

Inspired by various dotfiles repositories and macOS setup guides from the community.
