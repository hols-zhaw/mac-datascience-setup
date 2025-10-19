# 🧰 macOS Data Science Environment Setup

This Makefile automates the setup of a complete development environment for data science on macOS. It uses Homebrew for package management and Conda for Python environment setup. Configuration is defined in `config.yml`.

## 📦 Features
- Installs essential command-line tools and fonts via **Homebrew**
- Installs **Conda/Mamba** (using Miniforge) if not already available
- Creates or updates a **data science environment** from `environment.yml`
- Adds additional Homebrew taps for specific apps
- Ensures a consistent, reproducible setup with minimal manual steps

## 🧑‍💻 Usage

### Prerequisites
1. **Install Xcode Command Line Tools** (if not already installed):
   ```bash
   xcode-select --install
   ```
2. **Ensure Homebrew is installed** (the Makefile will install it if missing).

### Quick Start
Run the full setup:
```bash
make all
```

### Individual Targets
Run specific parts of the setup as needed:
- **Install CLI tools (formulae):**
  ```bash
  make tools
  ```
- **Add Homebrew taps:**
  ```bash
  make taps
  ```
- **Install GUI apps (casks):**
  ```bash
  make apps
  ```
- **Install fonts:**
  ```bash
  make fonts
  ```
- **Set up Python environment:**
  ```bash
  make python
  ```
- **Update all installed packages:**
  ```bash
  make update
  ```
- **Clean up caches:**
  ```bash
  make clean
  ```

## ⚙️ Configuration
- **`config.yml`**: Defines the tools, apps, fonts, and Homebrew taps to install.
  - Example sections: `tools`, `apps`, `fonts`, `taps`
- **`environment.yml`**: Specifies the Python environment, including dependencies and channels.

## 🧹 Reproducibility
You can safely re-run any target; the Makefile checks for existing installations and skips redundant steps.

## 📝 Notes
- The `config.yml` file includes detailed comments explaining each section.
- The `Makefile` is modular and well-documented for easy customization.
