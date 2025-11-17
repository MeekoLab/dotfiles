# Quick Start Guide

## 🚀 Install in One Command

### Windows 11
```powershell
irm https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/windows.ps1 | iex
```

### macOS
```bash
curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/macos.sh | bash
```

### Linux (openSUSE Tumbleweed)
```bash
curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/linux.sh | bash
```

## ✏️ Customize

```bash
# Edit your personal info
chezmoi edit ~/.chezmoi.toml.tmpl
# Change name and email

# Add your own dotfiles
chezmoi add ~/.vimrc
chezmoi add ~/.tmux.conf

# See what will change
chezmoi diff

# Apply changes
chezmoi apply
```

## 🎁 What You Get

- **100+ shell aliases** - shortcuts for everything
- **50+ custom functions** - productivity boosters
- **Beautiful prompts** - with git branch info
- **Dev tools** - nvm, pyenv, rust auto-installed
- **Apps** - platform-specific essentials
- **Editor configs** - VS Code, Terminal ready to go

## 💡 Most Useful Aliases

```bash
# Navigation
..          # cd ..
...         # cd ../..
mkcd foo    # mkdir foo && cd foo

# Git
g           # git
gs          # git status
ga .        # git add .
gc -m "msg" # git commit
gp          # git push
gl          # git log (pretty)

# Docker
d           # docker
dc          # docker-compose
dps         # docker ps
dex <id>    # docker exec -it <id> bash

# Chezmoi
ch          # chezmoi
cha         # chezmoi apply
chd         # chezmoi diff
chu         # chezmoi update
```

## 📚 Learn More

- Full docs: [README.md](README.md)
- Architecture: [CLAUDE.md](CLAUDE.md)
- openSUSE guide: [docs/opensuse-setup.md](docs/opensuse-setup.md)

---

**Made with ❤️ by [MeekoLab](https://github.com/MeekoLab)**
