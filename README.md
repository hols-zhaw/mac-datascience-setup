# macOS Data Science Setup

Automated setup for a complete data science development environment on macOS using Homebrew and Conda.

## Goals

- **Reproducible environment**: Complete setup from a fresh macOS install
- **Idempotent**: Safe to run multiple times, updates existing installations
- **Self-documenting**: Clear terminal output shows what's happening
- **Minimal manual steps**: One command to set up everything

## What Gets Installed

### System Tools (via Homebrew)

- Package managers: Homebrew, mas (Mac App Store CLI)
- Development tools: git, gh, wget, pandoc, typst
- Python tooling: uv (package installer), miniforge (conda/mamba)
- Utilities: fd, ripgrep, jq, yq, gnupg

### Applications (via Brewfile)

- Development: VS Code, iTerm2, GitHub Desktop, Docker Desktop
- LaTeX: MacTeX, IguanaTeX for PowerPoint
- Productivity: ChatGPT, Claude, Proton Drive, Proton VPN
- Research: Zotero, NetLogo, Safe Exam Browser
- Communication: Zoom, Spotify, Google Chrome

### Fonts

- Fira Code (monospace with ligatures)
- Fira Sans

### Python Environment

- Python 3.13 with data science stack from `environment.yml`
- Packages: numpy, pandas, matplotlib, seaborn, scipy, scikit-learn
- ML/Stats: pytorch, botorch, ax-platform, pymc, statsmodels
- Simulation: salabim, statannotations
- Development: jupyter, black, black-jupyter

## Usage

### Complete Setup

Run everything in sequence:

```bash
make all
```

### Individual Steps

Run specific parts as needed:

```bash
make homebrew    # Install Xcode tools and Homebrew
make bundle      # Install Brewfile packages
make python      # Setup Python environment
```

## Configuration Files

- **`Makefile`**: Orchestrates the setup process
- **`Brewfile`**: Defines all Homebrew packages, casks, and fonts
- **`environment.yml`**: Specifies Python environment and dependencies

## Requirements

- macOS (tested on Apple Silicon)
- Internet connection
- Administrator access (for initial Homebrew installation)

## Customization

1. Edit `Brewfile` to add/remove packages and applications
2. Edit `environment.yml` to modify Python packages
3. Adjust constants at the top of `Makefile` if needed

## Notes

- First run requires interaction for Xcode Command Line Tools installation
- Applications install to `~/Applications` by default
- Shell configuration is added to `~/.zprofile` and `~/.zshenv`
- Conda is configured to not auto-activate the base environment

## Further Tools to Explore

### Mac App Store CLI (`mas`)

Install Mac App Store apps via command line:

```bash
mas list                    # List installed apps
mas "Xcode", id: 497799835  # Add to Brewfile
```

### Homebrew Graph

Visualize dependencies of installed formulae:

- Repository: https://github.com/martido/homebrew-graph

### Chezmoi - Dotfiles Manager

Manage dotfiles across machines:

- Website: https://chezmoi.io/
- Install: `brew install chezmoi`
- Quick start: https://chezmoi.io/quick-start/

## Known Issues

### LaTeX Code Formatting in VS Code

Code formatting with the LaTeX Workshop extension requires additional Perl modules after installing MacTeX:

```bash
cpan -i YAML::Tiny File::HomeDir Unicode::GCString
```

But still may encounter errors; further troubleshooting is be needed.

## License

MIT License - see [LICENSE](LICENSE) file for details.
