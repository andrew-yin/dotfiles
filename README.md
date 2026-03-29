# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).
Bootstrap installs shared CLI packages on macOS and Linux. macOS-only apps and App Store items are skipped safely on Linux.

## Setup

```bash
chezmoi init --apply https://github.com/andrew-yin/dotfiles.git
```

For package installation without chezmoi, run:

```bash
./install.sh
```

Package installation is fail-fast so bootstrap issues are visible immediately.
