#!/usr/bin/env bash
#
# link-dotfiles.sh — Idempotent symlink installer. Creates links from this repo
# into $HOME so shell, Kitty, and Starship use the repo as source of truth.
#
# Run from the repo root. Safe to run multiple times.
# If a real file exists at the target (not a symlink), it is backed up to
# <target>.bak.<timestamp> before linking (no overwrite). Existing symlinks are force-updated.
#

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$HOME" ]]; then
  echo "ERROR: HOME is not set." >&2
  exit 1
fi

echo "Dotfiles repo: $REPO_ROOT"
echo "HOME: $HOME"
echo ""

# Ensure config directories exist (absolute paths)
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config"

# Link repo file to system path. Backs up real files; force-updates symlinks.
link() {
  local src="$1"
  local dst="$2"
  if [[ ! -e "$src" ]]; then
    echo "SKIP (missing): $src" >&2
    return 0
  fi

  if [[ -L "$dst" ]]; then
    ln -sfn "$src" "$dst"
    echo "LINK (updated): $dst -> $src"
  elif [[ -e "$dst" ]]; then
    backup="${dst}.bak.$(date +%s)"
    mv "$dst" "$backup"
    echo "BACKUP: $dst -> $backup"
    ln -sfn "$src" "$dst"
    echo "LINK: $dst -> $src"
  else
    ln -sfn "$src" "$dst"
    echo "LINK: $dst -> $src"
  fi
}

# Shell
link "$REPO_ROOT/zshrc" "$HOME/.zshrc"

# Kitty
link "$REPO_ROOT/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Starship
link "$REPO_ROOT/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "Done. Reload shell config: source ~/.zshrc"
