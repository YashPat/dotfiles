#!/usr/bin/env bash
#
# bootstrap.sh — One-shot setup for a new Mac: installs Homebrew (if missing),
# runs brew bundle from Brewfile, then runs link-dotfiles.sh so config is
# symlinked into $HOME.
#
# Run from the repo root after cloning. Idempotent: safe to run multiple times.
# Prerequisite: Xcode Command Line Tools (xcode-select -p). Install with:
#   xcode-select --install
#

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
trap 'e=$?; if [[ $e -ne 0 ]]; then echo "Bootstrap failed before linking. Run ./link-dotfiles.sh to link config." >&2; fi; exit $e' EXIT

# Bootstrap is for macOS (Homebrew and formulae are Mac-oriented here)
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: bootstrap.sh is for macOS only. On this machine, run link-dotfiles.sh after installing prerequisites." >&2
  exit 1
fi

# Ensure brew is in PATH (Apple Silicon puts it in /opt/homebrew)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Reload so brew is in PATH (Apple Silicon or Intel)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed."
fi

# Install everything from Brewfile (idempotent: already installed is a no-op)
if [[ -f "$REPO_ROOT/Brewfile" ]]; then
  echo "Installing from Brewfile..."
  brew bundle --file="$REPO_ROOT/Brewfile"
else
  echo "No Brewfile found, installing Starship, Kitty, eza..."
  brew install starship kitty eza
fi

# Link dotfiles into $HOME (idempotent)
if [[ ! -f "$REPO_ROOT/link-dotfiles.sh" ]]; then
  echo "ERROR: link-dotfiles.sh not found at $REPO_ROOT" >&2
  exit 1
fi
echo ""
bash "$REPO_ROOT/link-dotfiles.sh"

echo ""
echo "Bootstrap done. Install a Nerd Font in Kitty for Starship symbols, then: source ~/.zshrc"
