# mac-datascience-setup/Makefile
# Automated macOS data science development environment setup
#
# This Makefile orchestrates the complete setup of a data science environment on macOS:
#   - Installs Xcode Command Line Tools and Homebrew package manager
#   - Installs all packages, applications, and fonts from Brewfile
#   - Configures Conda/Mamba and creates Python environment from environment.yml
#
# Usage:
#   make all       - Run complete setup (homebrew → bundle → python)
#   make homebrew  - Install and configure Homebrew only
#   make bundle    - Install Brewfile packages only
#   make python    - Setup Python environment only
#
# All targets are idempotent and can be run multiple times safely.

# Configuration
BREWFILE := Brewfile
BREW := /opt/homebrew/bin/brew
ENV_FILE := environment.yml
DEFAULT_ENV_NAME := default

.PHONY: all homebrew bundle python latex-perl

# --- Main target: Complete setup ---
all: homebrew bundle python
	@echo ""
	@echo "=========================================="
	@echo "✅ Complete setup finished successfully!"
	@echo "=========================================="
	@echo ""
	@echo "ℹ️  Optional: Run 'make latex-perl' to install Perl modules for latexindent"
	@echo ""

# --- Step 1: Homebrew installation and configuration ---
# Installs Xcode Command Line Tools (prerequisite for Homebrew)
# Installs Homebrew package manager with proper permissions
# Configures shell environment in ~/.zprofile and cask options in ~/.zshenv
# Idempotent: Safe to run multiple times, skips if already configured
homebrew:
	@echo "=========================================="
	@echo "==> Step 1: Homebrew Setup"
	@echo "=========================================="
	@echo ""
	@echo "Checking Xcode Command Line Tools..."
	@if ! xcode-select -p >/dev/null 2>&1; then \
		echo "  ⬇️  Installing Xcode Command Line Tools..."; \
		xcode-select --install; \
		echo ""; \
		echo "  ⚠️  Please complete the installation in the dialog that appeared,"; \
		echo "      then run 'make homebrew' again to continue."; \
		echo ""; \
		exit 1; \
	else \
		echo "  ✅ Xcode Command Line Tools are installed"; \
	fi
	@echo ""
	@echo "Checking Homebrew installation..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "  ⬇️  Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo ""; \
		echo "  Setting up permissions..."; \
		sudo chown -R $$USER $$($(BREW) --prefix)/* || true; \
		chmod u+w $$($(BREW) --prefix)/* || true; \
		echo "  ✅ Homebrew installed successfully"; \
	else \
		echo "  ✅ Homebrew is already installed"; \
	fi
	@echo ""
	@echo "Configuring shell environment..."
	@eval "$$($(BREW) shellenv)" || true
	@if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then \
		echo "  Adding Homebrew to ~/.zprofile..."; \
		echo '' >> ~/.zprofile; \
		echo '# Homebrew' >> ~/.zprofile; \
		echo 'eval "$$($(BREW) shellenv)"' >> ~/.zprofile; \
		echo "  ✅ Homebrew path configured in ~/.zprofile"; \
	else \
		echo "  ✅ Homebrew already configured in ~/.zprofile"; \
	fi
	@if ! grep -q 'HOMEBREW_CASK_OPTS' ~/.zshenv 2>/dev/null; then \
		echo "  Configuring cask installation directory..."; \
		echo 'export HOMEBREW_CASK_OPTS="--appdir=$$HOME/Applications"' >> ~/.zshenv; \
		echo "  ✅ Cask apps will install to ~/Applications"; \
	else \
		echo "  ✅ Cask options already configured in ~/.zshenv"; \
	fi
	@echo ""
	@echo "🍺 Homebrew setup complete!"
	@echo ""

# --- Step 2: Brewfile bundle installation ---
# Installs all packages, applications, and fonts defined in $(BREWFILE)
# Sources ~/.zshenv to respect HOMEBREW_CASK_OPTS for application directory
# Idempotent: Safe to run multiple times, installs only missing packages
bundle: homebrew
	@echo "=========================================="
	@echo "==> Step 2: Brewfile Bundle Installation"
	@echo "=========================================="
	@echo ""
	@echo "Installing packages from $(BREWFILE)..."
	@source ~/.zshenv 2>/dev/null || true && \
		eval "$$($(BREW) shellenv)" && \
		brew bundle --file=$(BREWFILE)
	@echo ""
	@echo "✅ All Brewfile packages installed!"
	@echo ""

# --- Step 3: Python environment setup ---
# Verifies Conda installation and configures shell integration
# Detects mamba for faster operations (falls back to conda if not available)
# Creates or updates Python environment from $(ENV_FILE) specification
# Steps:
#   1. Verify conda is installed (required for shell initialization)
#   2. Initialize conda for zsh with proper shell hooks
#   3. Configure conda to not auto-activate base environment
#   4. Parse environment name from $(ENV_FILE) or use $(DEFAULT_ENV_NAME)
#   5. Detect mamba availability (faster alternative to conda)
#   6. Create new environment or update existing one (with --prune flag)
#   7. Clean package cache to reclaim disk space
# Idempotent: Safe to run multiple times, updates environment if it exists
python:
	@echo "=========================================="
	@echo "==> Step 3: Python Environment Setup"
	@echo "=========================================="
	@echo ""
	@echo "Verifying Conda installation..."
	@if ! command -v conda >/dev/null 2>&1; then \
		echo "  ❌ Conda is not installed"; \
		echo ""; \
		echo "  Conda is required for Python environment management."; \
		echo "  Install Miniforge via Homebrew:"; \
		echo ""; \
		echo "    brew install --cask miniforge"; \
		echo ""; \
		echo "  Then restart your shell and run 'make python' again."; \
		echo ""; \
		exit 1; \
	fi
	@echo "  ✅ Conda is installed"
	@echo ""
	@echo "Initializing Conda for zsh shell..."
	@if grep -q 'conda initialize' ~/.zshrc 2>/dev/null; then \
		echo "  ✅ Conda already initialized in ~/.zshrc"; \
	else \
		echo "  Configuring conda shell integration..."; \
		eval "$$(conda shell.zsh hook 2>/dev/null || true)"; \
		if conda init zsh >/dev/null 2>&1; then \
			echo "  ✅ Conda initialized for zsh"; \
			echo "  ℹ️  Changes take effect in new shell sessions"; \
		else \
			echo "  ⚠️  Conda init completed with warnings (continuing)"; \
		fi; \
	fi
	@echo ""
	@echo "Configuring Conda settings..."
	@if conda config --get auto_activate_base 2>/dev/null | grep -q 'True'; then \
		echo "  Setting auto_activate_base=false..."; \
		conda config --set auto_activate_base false 2>/dev/null || true; \
		echo "  ✅ Base environment will not auto-activate"; \
	else \
		echo "  ✅ auto_activate_base already set to false"; \
	fi
	@echo ""
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "ℹ️  No $(ENV_FILE) found, skipping environment creation"; \
		echo ""; \
		echo "   To create a Python environment:"; \
		echo "   1. Add an $(ENV_FILE) file to this directory"; \
		echo "   2. Run 'make python' again"; \
		echo ""; \
		exit 0; \
	fi
	@echo "Parsing environment configuration..."
	@if command -v yq >/dev/null 2>&1; then \
		ENV_NAME="$$(yq -r '.name // "$(DEFAULT_ENV_NAME)"' $(ENV_FILE) 2>/dev/null || echo $(DEFAULT_ENV_NAME))"; \
	else \
		ENV_NAME="$$(grep '^name:' $(ENV_FILE) 2>/dev/null | sed 's/^name:[[:space:]]*//' || echo $(DEFAULT_ENV_NAME))"; \
	fi; \
	if [ -z "$$ENV_NAME" ] || [ "$$ENV_NAME" = "null" ]; then \
		ENV_NAME="$(DEFAULT_ENV_NAME)"; \
		echo "  ⚠️  No name found in $(ENV_FILE), using: $$ENV_NAME"; \
	else \
		echo "  Environment name: $$ENV_NAME"; \
	fi; \
	echo ""; \
	echo "Detecting package manager..."; \
	if command -v mamba >/dev/null 2>&1; then \
		CONDA_CMD=mamba; \
		echo "  ✅ Using mamba (faster package operations)"; \
	else \
		CONDA_CMD=conda; \
		echo "  ✅ Using conda"; \
	fi; \
	echo ""; \
	echo "Checking environment status..."; \
	if $$CONDA_CMD env list 2>/dev/null | grep -q "^$$ENV_NAME[[:space:]]"; then \
		echo "  Found existing environment '$$ENV_NAME'"; \
		echo "  ⬇️  Updating environment..."; \
		if $$CONDA_CMD env update -f $(ENV_FILE) -n $$ENV_NAME --yes --prune 2>&1; then \
			echo "  ✅ Environment '$$ENV_NAME' updated successfully"; \
		else \
			echo "  ❌ Failed to update environment '$$ENV_NAME'"; \
			echo ""; \
			exit 1; \
		fi; \
	else \
		echo "  Environment '$$ENV_NAME' not found"; \
		echo "  ⬇️  Creating new environment..."; \
		if $$CONDA_CMD env create -f $(ENV_FILE) -n $$ENV_NAME --yes 2>&1; then \
			echo "  ✅ Environment '$$ENV_NAME' created successfully"; \
		else \
			echo "  ❌ Failed to create environment '$$ENV_NAME'"; \
			echo ""; \
			exit 1; \
		fi; \
	fi; \
	echo ""; \
	echo "Cleaning package cache..."; \
	if $$CONDA_CMD clean -yaf >/dev/null 2>&1; then \
		echo "  ✅ Cache cleaned successfully"; \
	else \
		echo "  ⚠️  Cache cleanup completed with warnings"; \
	fi; \
	echo ""; \
	echo "🐍 Python environment ready!"; \
	echo ""; \
	echo "   Activate with: conda activate $$ENV_NAME"; \
	echo ""

# --- Step 4 (Optional): Perl modules for latexindent ---
# Installs Perl modules that enable code formatting with latexindent.
# These modules allow the LaTeX Workshop extension in VS Code to format .tex files.
# Modules are installed system-wide using macOS system Perl (/usr/bin/perl) which
# latexindent is configured to use by default.
# Purpose: Enable latexindent code formatting functionality (included in Brewfile)
# Note: Requires administrator password for sudo cpan installation
latex-perl:
	@echo "=========================================="
	@echo "==> Optional: Perl Modules for latexindent"
	@echo "=========================================="
	@echo ""
	@echo "Installing Perl modules..."
	@echo ""
	@if ! command -v latexindent >/dev/null 2>&1; then \
		echo "  ⚠️  latexindent not found"; \
		echo ""; \
		echo "  These modules are useful when latexindent is installed."; \
		echo "  To install MacTeX (which includes latexindent):"; \
		echo ""; \
		echo "    make bundle"; \
		echo ""; \
		echo "  You can install the modules now or run 'make latex-perl' later."; \
		echo ""; \
		read -p "  Continue installing Perl modules anyway? [y/N] " -n 1 -r; \
		echo ""; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "  Cancelled."; \
			echo ""; \
			exit 0; \
		fi; \
	else \
		echo "  ✅ latexindent found: $$(command -v latexindent)"; \
	fi
	@echo ""
	@echo "ℹ️  Installing Perl modules system-wide (requires sudo)"
	@echo "   This allows latexindent to use these modules for code formatting."
	@echo ""
	@echo "Installing File::HomeDir..."
	@sudo cpan -i File::HomeDir
	@echo ""
	@echo "Installing YAML::Tiny..."
	@sudo cpan -i YAML::Tiny
	@echo ""
	@echo "Installing Unicode::GCString..."
	@sudo cpan -i Unicode::GCString
	@echo ""
	@echo "✅ Perl modules installed successfully!"
	@echo ""
	@echo "📝 Perl modules are now available for latexindent"
	@echo "   (LaTeX Workshop extension can now use latexindent for formatting)"
	@echo ""
