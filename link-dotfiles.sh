#!/usr/bin/env bash
#
# link-dotfiles.sh — Idempotent symlink installer. Links this repo into $HOME
# so shell, Kitty, Starship, and Neovim use the repo as source of truth.
# Offline: no installs, no clones. Safe to run any time.
#
# A real file at the target is backed up to <target>.bak.<timestamp> first.
# Existing symlinks are updated in place.
#

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config" "$HOME/.local/bin"

link() {
  local src="$1" dst="$2"
  if [[ ! -e "$src" ]]; then
    echo "SKIP (missing): $src" >&2
    return 0
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="${dst}.bak.$(date +%s)"
    mv "$dst" "$backup"
    echo "BACKUP: $dst -> $backup"
  fi
  ln -sfn "$src" "$dst"
  echo "LINK: $dst -> $src"
}

link "$REPO_ROOT/zshrc"         "$HOME/.zshrc"
link "$REPO_ROOT/starship.toml" "$HOME/.config/starship.toml"
# Whole dirs, so `kitten themes` can write current-theme.conf next to kitty.conf
link "$REPO_ROOT/kitty"         "$HOME/.config/kitty"
link "$REPO_ROOT/nvim"          "$HOME/.config/nvim"
link "$REPO_ROOT/bin/kitten"    "$HOME/.local/bin/kitten"   # theme picks reload Kitty
link "$REPO_ROOT/bin/kshader"   "$HOME/.local/bin/kshader"  # shader picker
# wall CLI lives in its own repo (bootstrap.sh clones it)
link "$HOME/Code/wall/wall"     "$HOME/.local/bin/wall"

echo ""
echo "Done. Reload shell config: source ~/.zshrc"
