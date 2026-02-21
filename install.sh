#!/usr/bin/env bash
#
# install.sh — Idempotent symlink installer for Yash's dotfiles.
# Run from ~/dotfiles. Safe to run multiple times.
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

# Create config directories if needed
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config"

# Symlink: repo file -> system path (force, no-dereference)
link() {
  local src="$1"
  local dst="$2"
  if [[ ! -e "$src" ]]; then
    echo "SKIP (missing): $src" >&2
    return 0
  fi
  ln -sfn "$src" "$dst"
  echo "LINK: $dst -> $src"
}

# Shell
link "$REPO_ROOT/zshrc" "$HOME/.zshrc"

# Git
link "$REPO_ROOT/gitconfig" "$HOME/.gitconfig"

# Kitty
link "$REPO_ROOT/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Starship
link "$REPO_ROOT/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "Done. Reload shell config: source ~/.zshrc"
