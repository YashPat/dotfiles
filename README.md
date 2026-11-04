# Yash's Dotfiles

macOS shell, terminal, and editor config. The files live here; `$HOME` holds
symlinks into this repo, so editing a file here changes it everywhere.

## Setup on a new Mac

```bash
xcode-select --install
git clone https://github.com/YashPat/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
source ~/.zshrc
```

## Scripts

| Script | What it does |
|--------|--------------|
| `bootstrap.sh` | New Mac: installs Homebrew, everything in `Brewfile`, clones the [wall](https://github.com/YashPat/wall) CLI, then runs `link-dotfiles.sh`. |
| `link-dotfiles.sh` | Creates the symlinks (it is the list of what is linked). Offline and idempotent; backs up real files to `<path>.bak.<timestamp>`. CI runs it on every push. |

Packages: add or remove them in `Brewfile`, then `brew bundle`.

## Rules

1. **Edit files in `~/dotfiles`**, not through the symlinks.
2. **Point tool output at the repo**, e.g.
   `starship preset pastel-powerline -o ~/dotfiles/starship.toml`.
   Writing to `~/.config/starship.toml` can replace the link with a real file.
3. **A link broke?** Re-run `./link-dotfiles.sh`, then `adjust` (`source ~/.zshrc`).
