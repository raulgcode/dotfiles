# macOS Development Environment Setup

Automated setup script for configuring a new Mac with essential development tools, applications, and configurations.

## Quick Start

Run this single command to set up your entire development environment:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/setup.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

## What Gets Installed

### Applications

| Application | Description |
|-------------|-------------|
| Google Chrome | Web browser (set as default) |
| Visual Studio Code | Code editor with extensions |
| Docker Desktop | Container platform |
| Postman | API development platform |

### Development Tools

| Tool | Description |
|------|-------------|
| Homebrew | Package manager for macOS |
| Xcode Command Line Tools | Apple developer tools |
| Git | Version control |
| Python 3.12 | Programming language |
| Node.js (via nvm) | JavaScript runtime |
| nvm | Node Version Manager |
| GitHub CLI (gh) | GitHub command-line tool |

### ZSH Enhancements

| Plugin | Description |
|--------|-------------|
| zsh-autosuggestions | Fish-like autosuggestions |
| zsh-syntax-highlighting | Syntax highlighting for zsh |

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
├── README.md                    # This file
├── setup.sh                     # Main entry point
├── configs/
│   ├── Brewfile                 # Homebrew bundle file
│   └── vscode/
│       ├── extensions.txt       # VS Code extensions list
│       └── settings.json        # VS Code settings
└── scripts/
    ├── utils.sh                 # Shared helper functions
    ├── install-xcode.sh         # Xcode CLI tools
    ├── install-brew.sh          # Homebrew
    ├── install-apps.sh          # GUI applications
    ├── install-dev-tools.sh     # Development tools
    ├── install-vscode.sh        # VS Code configuration
    ├── install-zsh-plugins.sh   # ZSH plugins
    └── configure-macos.sh       # macOS preferences
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
```

## Post-Installation Steps

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

## Troubleshooting

### Homebrew Issues

```bash
# Update Homebrew
brew update

# Fix any issues
brew doctor

# Clean up old versions
brew cleanup
```

### VS Code CLI Not Working

```bash
# Add to PATH manually
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
```

### nvm Not Found

```bash
# Reload shell configuration
source ~/.zshrc

# Or manually load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### Permission Errors

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/Homebrew
sudo chown -R $(whoami) /usr/local/var/homebrew
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
