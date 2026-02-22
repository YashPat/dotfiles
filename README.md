# Yash's Dotfiles

Single source of truth for macOS shell and terminal configuration. Everything lives in `~/dotfiles`; the rest of the system uses **symbolic links** so edits here are reflected everywhere.

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

## Scripts

| Script | Purpose | When to use |
|--------|---------|-------------|
| **`link-dotfiles.sh`** | Creates symlinks from this repo into `$HOME` (and `~/.config`). Idempotent; backs up existing real files to `<path>.bak.<timestamp>` before linking. | You already have Homebrew and tools installed; you only need to (re)link config. Also what CI tests. |
| **`bootstrap.sh`** | Installs Homebrew (if missing), runs `brew install starship kitty eza`, then runs `link-dotfiles.sh`. Idempotent. | New Mac: clone repo, run this once to get everything. |

**Maintainability:** Only `link-dotfiles.sh` is tested in CI. It has a single responsibility (symlinks) and no external installs, so it stays reliable. `bootstrap.sh` is a convenience wrapper; change it when you add/remove prerequisites.

---

## How it works

This repo uses **symbolic links**: the real files live in `~/dotfiles`, and your home directory holds small "pointer" files that redirect to them. When an app reads `~/.zshrc`, it actually gets the content from `~/dotfiles/zshrc`.

**Why symlinks?** One source of truth: you edit and version-control the files in the repo, and every app (zsh, Kitty, etc.) sees the same content through the links. No copying, no drift—and on a new machine you just clone and run `link-dotfiles.sh` (or `bootstrap.sh`) to get the same setup.

**Example:** after running `link-dotfiles.sh`:

| Real file (in repo)   | Symlink (what apps see)        |
|-----------------------|---------------------------------|
| `~/dotfiles/zshrc`    | `~/.zshrc` → points to the repo |
| `~/dotfiles/kitty.conf` | `~/.config/kitty/kitty.conf` → points to the repo |

So you always **edit the file inside `~/dotfiles`**; the symlinks just make that file appear where your shell and apps expect it.

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

## Setup on a New Mac

1. Install Xcode Command Line Tools if needed: `xcode-select --install`

2. Clone the repo (replace with your real repo URL):

   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

3. **Option A — One command (new Mac):** Run bootstrap to install Homebrew, Starship, Kitty, eza, and link config:

   ```bash
   chmod +x bootstrap.sh link-dotfiles.sh && ./bootstrap.sh
   ```

   **Option B — Links only:** If you already have [prerequisites](#prerequisites) installed, just link the config:

   ```bash
   chmod +x link-dotfiles.sh && ./link-dotfiles.sh
   ```

4. Install a [Nerd Font](https://www.nerdfonts.com/font-downloads) and set it in Kitty (e.g. in `kitty.conf`: `font_family JetBrainsMono Nerd Font`).

5. Reload your shell:

   ```bash
   source ~/.zshrc
   ```

---

## What Gets Linked

| Repo file       | System location                  |
|-----------------|----------------------------------|
| `zshrc`         | `~/.zshrc`                       |
| `kitty.conf`    | `~/.config/kitty/kitty.conf`     |
| `starship.toml` | `~/.config/starship.toml`        |

---

## CI

Every push and pull request to `main` runs [GitHub Actions](.github/workflows/test-install.yml):

- **link-dotfiles:** The link script runs in a fresh environment and all three symlinks are verified (no Homebrew or formulae—fast and deterministic).
- **bootstrap.sh:** On Linux, the workflow confirms bootstrap exits with the "macOS only" message (smoke test; full bootstrap is not run in CI).

Check the **Actions** tab on GitHub to confirm both pass.

---

## Troubleshooting

**Broken link (e.g. prompt or shell config not loading):**  
If a symlink points to a missing or moved file (e.g. repo was moved or a file was deleted):

1. Remove the broken link: `rm ~/.zshrc` (or the affected path).
2. Re-run the link script: `cd ~/dotfiles && ./link-dotfiles.sh`.

The script will recreate the link. Reload the shell with `source ~/.zshrc` if you fixed `~/.zshrc`.

---

## Shell note

`zshrc` defines `adjust="source ~/.zshrc"`. From any directory, run `adjust` to reload your config after editing dotfiles.
