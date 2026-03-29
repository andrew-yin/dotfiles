# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).
Bootstrap is macOS-friendly, but non-macOS hosts skip macOS-only setup safely.

## Setup

```bash
chezmoi init --apply https://github.com/andrew-yin/dotfiles.git
```

Package installation is fail-fast so bootstrap issues are visible immediately.
