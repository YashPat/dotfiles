#!/usr/bin/env bash
#
# bootstrap.sh — One-shot setup for a new Mac: Homebrew, the Brewfile,
# the wall CLI, then link-dotfiles.sh. Idempotent.
# Prerequisite: Xcode Command Line Tools (xcode-select --install).
#

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: bootstrap.sh is for macOS only. Run link-dotfiles.sh instead." >&2
  exit 1
fi

if [[ ! -x /opt/homebrew/bin/brew && ! -x /usr/local/bin/brew ]]; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

brew bundle --file="$REPO_ROOT/Brewfile"

# wall CLI (https://github.com/YashPat/wall); link-dotfiles.sh puts it on PATH
[[ -d "$HOME/Code/wall/.git" ]] || git clone https://github.com/YashPat/wall.git "$HOME/Code/wall"

bash "$REPO_ROOT/link-dotfiles.sh"

echo "Bootstrap done. Run: source ~/.zshrc"
