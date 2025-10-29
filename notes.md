# Homebrew notes

## Homebrew as standard user

https://gist.github.com/Justintime50/de232f266cea55faf82e9d65d5bd94c0

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo chown -R $USER $(brew --prefix)/*
chmod u+w $(brew --prefix)/*
```

- to have apps installed in the user's app folder add `export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"` to ~/.zshenv

## Mac App Store command-line interface

- `mas list` - lists installed apps
- in Brewfile: `mas "Xcode", id: 497799835`


## LaTeX Workshop & Code Formatter

Code formatting in LaTeX Workshop extension for VS Code requires `latexindent` to be installed. Is installed when installing the full MacTeX distribution via Homebrew Cask.

Still there's an error when trying to format a LaTeX document. Need to install some Perl modules:

```zsh
cpan -i YAML::Tiny File::HomeDir Unicode::GCStrin
```
