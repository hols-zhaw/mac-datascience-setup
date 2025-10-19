# mac-setup/Makefile
# Complete macOS data science setup using config.yaml
#
# This Makefile automates the setup of a development environment on macOS.
# It uses Homebrew for package management and Conda for Python environment setup.
# Configuration is defined in config.yml.

CONFIG_YML := config.yml
ENV_YML := environment.yml

.PHONY: all homebrew yq tools taps apps fonts python update clean

# --- Main target: Run all setup steps ---
all: homebrew yq tools taps apps fonts python
	@echo "✅ Complete setup finished."

# --- Step 1: Ensure Homebrew is installed ---
# Checks if Homebrew is installed; installs it if not.
homebrew:
	@echo "==> Checking Homebrew..."
	@which brew >/dev/null 2>&1 || ( \
		echo "⬇️ Homebrew not found. Installing..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	)
	@echo "🍺 Homebrew is ready."

# --- Step 2: Ensure yq is installed ---
# Installs yq, a YAML processor, if not already installed.
yq: homebrew
	@echo "==> Checking yq..."
	@brew list yq >/dev/null 2>&1 || brew install yq
	@echo "yq is ready."

# --- Step 3: Install CLI tools (formulae) ---
# Installs command-line tools specified in the 'tools' section of config.yml.
tools: yq
	@echo "==> Installing tools (formulae)..."
	@BREW_TOOLS="$$(yq '.tools[]' $(CONFIG_YML))"; \
	if [ -n "$$BREW_TOOLS" ]; then \
		echo "🔹 Installing: $$BREW_TOOLS"; \
		brew install $$BREW_TOOLS; \
	else \
		echo "No CLI tools specified in config.yml."; \
	fi
	@echo "✅ CLI tools installed."

# --- Step 4: Add Homebrew taps ---
# Adds additional Homebrew repositories (taps) specified in the 'taps' section of config.yml.
taps: yq
	@echo "==> Adding Homebrew taps..."
	@TAPS="$$(yq '.taps[]' $(CONFIG_YML))"; \
	if [ -n "$$TAPS" ]; then \
		for tap in $$TAPS; do \
		  echo "🔹 Adding tap $$tap"; \
		  brew tap $$tap; \
		done; \
	else \
		echo "No taps specified in config.yml."; \
	fi
	@echo "✅ Homebrew taps added."

# --- Step 5: Install GUI apps (casks) ---
# Installs GUI applications specified in the 'apps' section of config.yml.
apps: yq taps
	@echo "==> Installing apps (casks)..."
	@APPS="$$(yq '.apps[]' $(CONFIG_YML))"; \
	if [ -n "$$APPS" ]; then \
		for app in $$APPS; do \
		  echo "🔹 Installing $$app"; \
		  brew install --cask --no-quarantine $$app; \
		done; \
	else \
		echo "No apps specified in config.yml."; \
	fi
	@echo "✅ Apps installed."

# --- Step 6: Install fonts ---
# Installs fonts specified in the 'fonts' section of config.yml.
fonts: yq
	@echo "==> Installing fonts..."
	@FONTS="$$(yq '.fonts[]' $(CONFIG_YML))"; \
	if [ -n "$$FONTS" ]; then \
		brew install --cask $$FONTS; \
	else \
		echo "No fonts specified in config.yml."; \
	fi
	@echo "✅ Fonts installed."

# --- Step 7: Python setup + environment ---
# Installs Python tools and sets up the Conda environment defined in environment.yml.
python: homebrew
	@echo "==> Installing Python tools..."
	@brew install miniforge || echo "Miniforge already installed"
	@brew install uv || echo "uv already installed"

	@echo "==> Initializing conda for zsh..."
	@eval "$$(conda shell.zsh hook)" || { echo "Error: Failed to initialize conda shell."; exit 1; }
	conda init zsh || echo "Conda already initialized"
	conda config --set auto_activate_base false

	@echo "==> Creating/updating default data science environment..."
	@ENV_NAME="$$(yq -r '.default_env_name' $(CONFIG_YML))"; \
	if conda env list | grep -q "$$ENV_NAME"; then \
		echo "🔁 Updating environment $$ENV_NAME..."; \
		mamba env update -f $(ENV_YML) -n $$ENV_NAME --yes; \
	else \
		echo "🆕 Creating environment $$ENV_NAME..."; \
		mamba env create -f $(ENV_YML) -n $$ENV_NAME --yes; \
	fi
	@echo "✅ Python environment ready."

# --- Update system ---
# Updates all installed Homebrew packages and the Conda environment.
update:
	@echo "==> Updating Homebrew packages..."
	brew update && brew upgrade
	@echo "==> Updating Python environment..."
	@ENV_NAME="$$(yq -r '.default_env_name' $(CONFIG_YML))"; \
	mamba update --all -n $$ENV_NAME
	@echo "✅ System updated."

# --- Clean up ---
# Cleans up Homebrew caches and Conda caches.
clean:
	@echo "==> Cleaning up Homebrew..."
	brew cleanup
	@echo "==> Cleaning global Python caches..."
	mamba clean -afy
	@echo "✨ Cleanup done."
