# Yash's Dotfiles

Single source of truth for macOS shell, terminal, and Git configuration. Everything lives in `~/dotfiles`; the rest of the system uses **symbolic links** so edits here are reflected everywhere.

---

## Prerequisites

Before running the installer or relying on this config, ensure these are installed:

| Tool | Purpose |
|------|---------|
| **Homebrew** | Package manager; used for zsh plugins (syntax-highlighting, autosuggestions), eza, etc. |
| **Starship** | Cross-shell prompt (configured in `starship.toml`). |
| **Kitty** | Terminal emulator (configured in `kitty.conf`). |
| **eza** | Modern `ls` replacement; `zshrc` aliases `ls`/`ll`/`tree` to eza. |

Install via Homebrew if needed: `brew install starship kitty eza`.

**Nerd Font:** Starship uses symbols (icons/glyphs) that require a **Nerd Font**. Install one (e.g. [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)) and set it as the font in Kitty (e.g. in `kitty.conf`: `font_family JetBrainsMono Nerd Font`) so the prompt renders correctly.

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
│  (symlinks — they "point" back into ~/dotfiles)                   │
└─────────────────────────────────────────────────────────────────┘
```

- **Repo** = real files.  
- **System** = links that point into the repo. Editing a "file" in `~/.zshrc` or `~/.config/starship.toml` is really editing the file inside `~/dotfiles`.

---

## Golden Rules of Maintenance

**Rule 1: Edit the source.**  
Always edit files **inside** `~/dotfiles`. The paths under `~` or `~/.config` are symlinks; changing them in an editor is changing the repo files.

**Rule 2: Redirect tool output.**  
Commands like `starship preset -o [path]` must point to **`~/dotfiles/starship.toml`**, **not** the symlink at `~/.config/starship.toml`. Writing to the symlink target can replace the link with a real file and break the setup.

Example (correct):

```bash
starship preset pastel-powerline -o ~/dotfiles/starship.toml
```

**Rule 3: Sync with Git.**  
After changes you want to keep:

```bash
cd ~/dotfiles && git add -A && git status && git commit -m "Describe change" && git push
```

---

## Privacy note (gitconfig)

If this repo is **public**, the included `gitconfig` will be visible and may contain your name and email. To avoid leaking sensitive or work emails, use a **local override** that is not in the repo:

1. Keep only generic/safe defaults in `~/dotfiles/gitconfig`.
2. At the end of `~/dotfiles/gitconfig`, add:
   ```ini
   [include]
       path = ~/.gitconfig.local
   ```
3. Create `~/.gitconfig.local` (do **not** put it in the repo) with your real identity, e.g.:
   ```ini
   [user]
       name = Your Name
       email = you@example.com
   ```
   Git will read this after the symlinked config, so your private email stays off the repo.

---

## Setup on a New Mac

1. Clone the repo (replace with your real repo URL):

   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Install [prerequisites](#prerequisites) (Homebrew, Starship, Kitty, eza, and a Nerd Font in Kitty).

3. Run the installer (idempotent — safe to run more than once). Existing real files at target paths are backed up to `<path>.bak`; existing symlinks are force-updated:

   ```bash
   chmod +x install.sh && ./install.sh
   ```

4. Reload your shell:

   ```bash
   source ~/.zshrc
   ```

---

## What Gets Linked

| Repo file       | System location                  |
|-----------------|----------------------------------|
| `zshrc`         | `~/.zshrc`                       |
| `gitconfig`     | `~/.gitconfig`                   |
| `kitty.conf`    | `~/.config/kitty/kitty.conf`     |
| `starship.toml` | `~/.config/starship.toml`        |

---

## Troubleshooting

**Broken link (e.g. prompt or shell config not loading):**  
If a symlink points to a missing or moved file (e.g. repo was moved or a file was deleted):

1. Remove the broken link: `rm ~/.zshrc` (or the affected path).
2. Re-run the installer: `cd ~/dotfiles && ./install.sh`.

The script will recreate the link. Reload the shell with `source ~/.zshrc` if you fixed `~/.zshrc`.

---

## Shell note

`zshrc` defines `adjust="source ~/.zshrc"`. From any directory, run `adjust` to reload your config after editing dotfiles.
