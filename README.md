# Yash's Dotfiles

Single source of truth for macOS shell, terminal, and Git configuration. Everything lives in `~/dotfiles`; the rest of the system uses **symbolic links** so edits here are reflected everywhere.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  ~/dotfiles (this repo) — THE SOURCE OF TRUTH                    │
│  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────┐ │
│  │ zshrc        │ │ kitty.conf  │ │ starship.toml│ │ gitconfig│ │
│  └──────┬──────┘ └──────┬──────┘ └──────┬───────┘ └────┬─────┘ │
└─────────┼───────────────┼───────────────┼──────────────┼────────┘
          │               │               │              │
          │  ln -sf       │  ln -sf       │  ln -sf      │  ln -sf
          ▼               ▼               ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│  System (what apps actually read)                                 │
│  ~/.zshrc    ~/.config/kitty/kitty.conf   ~/.config/starship.toml  ~/.gitconfig
│  (symlinks — they “point” back into ~/dotfiles)                   │
└─────────────────────────────────────────────────────────────────┘
```

- **Repo** = real files.  
- **System** = links that point into the repo. Editing a “file” in `~/.zshrc` or `~/.config/starship.toml` is really editing the file inside `~/dotfiles`.

---

## Golden Rules of Maintenance

1. **Edit the source**  
   Always change files **inside** `~/dotfiles`, not the paths in your home directory. If you edit `~/.zshrc` in an editor, you’re editing the repo file because `~/.zshrc` is a symlink.

2. **Redirect tool output to the repo**  
   When a tool writes a config file (e.g. Starship presets), **always** point its output to the file in `~/dotfiles`. Otherwise the tool may **replace the symlink with a real file** and break the setup.  
   - **Starship:**  
     ```bash
     starship preset pastel-powerline -o ~/dotfiles/starship.toml
     ```  
     Do **not** use `-o ~/.config/starship.toml` — that can overwrite the symlink.

3. **Sync with Git**  
   After changes you want to keep:
   ```bash
   cd ~/dotfiles && git add -A && git status && git commit -m "Describe change" && git push
   ```

---

## Setup on a New Mac

1. Clone the repo (replace with your real repo URL):
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the installer (idempotent — safe to run more than once):
   ```bash
   chmod +x install.sh && ./install.sh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

You’ll have the same shell, Kitty, Starship, and Git config as on your main machine.

---

## What Gets Linked

| Repo file       | System location                  |
|-----------------|----------------------------------|
| `zshrc`         | `~/.zshrc`                       |
| `gitconfig`     | `~/.gitconfig`                   |
| `kitty.conf`    | `~/.config/kitty/kitty.conf`     |
| `starship.toml` | `~/.config/starship.toml`        |

---

## Shell note

`zshrc` includes `adjust="source ~/.zshrc"` (or similar). From any directory, run `adjust` to reload your config after editing dotfiles.
