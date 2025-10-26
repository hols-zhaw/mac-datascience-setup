# Homebrew notes

## Homebrew as standard user

https://gist.github.com/Justintime50/de232f266cea55faf82e9d65d5bd94c0

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo chown -R $USER $(brew --prefix)/*
chmod u+w $(brew --prefix)/*
```

to have apps installed in the user's app folder add `export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"` to ~/.zshenv


betterdisplay font-source-code-pro latexit-metadata safe-exam-browser chatgpt font-source-sans-3 mactex visual-studio-code claude github miniforge wailbrew docker-desktop google-chrome netlogo zoom font-fira-code iguanatexmac proton-drive zotero font-fira-sans iterm2 proton-mail font-inconsolata latexit protonvpn