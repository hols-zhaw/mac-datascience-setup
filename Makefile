# mac-setup/Makefile
# Complete macOS data science setup using Brewfile
#
# This Makefile automates the setup of a development environment on macOS.
# It uses Homebrew for package management and Conda for Python environment setup.

BREWFILE := Brewfile

.PHONY: all homebrew bundle python

# --- Main target: Run all setup steps ---
all: homebrew bundle python
	@echo "✅ Complete setup finished."

# --- Step 1: Install and configure Homebrew ---
# Installs Homebrew as standard user with proper permissions and cask settings
homebrew:
	@echo "==> Installing and configuring Homebrew..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "⬇️ Homebrew not found. Installing..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo ""; \
		echo "==> Setting up Homebrew permissions..."; \
		sudo chown -R $$USER $$(brew --prefix)/* || true; \
		chmod u+w $$(brew --prefix)/* || true; \
	fi
	@# Ensure Homebrew is available on PATH
	@eval "$$(/opt/homebrew/bin/brew shellenv)" || true
	@# Configure cask installation to user's Applications folder
	@if ! grep -q 'HOMEBREW_CASK_OPTS' ~/.zshenv 2>/dev/null; then \
		echo "==> Configuring cask installation directory..."; \
		echo 'export HOMEBREW_CASK_OPTS="--appdir=$$HOME/Applications"' >> ~/.zshenv; \
		echo "✅ Added HOMEBREW_CASK_OPTS to ~/.zshenv"; \
	else \
		echo "✅ HOMEBREW_CASK_OPTS already configured in ~/.zshenv"; \
	fi
	@echo "🍺 Homebrew is ready."

# --- Step 2: Install Brewfile bundle ---
# Installs all packages defined in the Brewfile
bundle: homebrew
	@echo "==> Installing Brewfile bundle..."
	@eval "$$(/opt/homebrew/bin/brew shellenv)" && \
		export HOMEBREW_CASK_OPTS="--appdir=$$HOME/Applications" && \
		brew bundle --file=$(BREWFILE)
	@echo "✅ Brewfile bundle installed."

# --- Step 3: Python setup + environment ---
# Checks for Conda/Mamba and sets up the Conda environment
python:
	@echo "==> Checking for Conda or Mamba..."
	@if ! command -v conda >/dev/null 2>&1 && ! command -v mamba >/dev/null 2>&1; then \
		echo "❌ Neither Conda nor Mamba is installed. Please install Miniforge via Homebrew (brew install --cask miniforge)."; \
		exit 1; \
	fi
	@echo "==> Initializing Conda for zsh (if available) and setting up environment..."
	@{ \
		# Initialize conda in this shell if available (non-fatal if missing) \
		if command -v conda >/dev/null 2>&1; then \
			eval "$$(conda shell.zsh hook 2>/dev/null || true)"; \
			if ! conda init zsh 2>&1 | tee /tmp/conda_init.log | grep -q "no change" ; then \
				if grep -q "already initialized" /tmp/conda_init.log; then \
					echo "Conda already initialized"; \
				else \
					echo "Warning: Conda init reported an issue (continuing):"; \
					cat /tmp/conda_init.log; \
				fi; \
			fi; \
			conda config --set auto_activate_base false || true; \
		fi; \
		\
		# If there's no environment.yml, skip gracefully \
		if [ ! -f environment.yml ]; then \
			echo "ℹ️  No environment.yml found. Skipping Conda environment setup."; \
			exit 0; \
		fi; \
		\
		# Determine environment name from file or default \
		ENV_NAME="$$(yq -r '.name // "default"' environment.yml 2>/dev/null || echo default)"; \
		\
		# Create or update the environment (prefer mamba if available) \
		if conda env list 2>/dev/null | grep -q "^$$ENV_NAME[[:space:]]"; then \
			echo "🔁 Updating environment $$ENV_NAME..."; \
			if command -v mamba >/dev/null 2>&1; then \
				mamba env update -f environment.yml -n $$ENV_NAME --yes; \
			else \
				conda env update -f environment.yml -n $$ENV_NAME --yes; \
			fi; \
		else \
			echo "🆕 Creating environment $$ENV_NAME..."; \
			if command -v mamba >/dev/null 2>&1; then \
				mamba env create -f environment.yml -n $$ENV_NAME --yes; \
			else \
				conda env create -f environment.yml -n $$ENV_NAME --yes; \
			fi; \
		fi; \
		echo "✅ Conda environment $$ENV_NAME is ready."; \
	}
