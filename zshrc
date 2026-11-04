# --- Aliases ---
alias adjust="source ~/.zshrc"
alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/.zshrc'
alias kconf='cursor ~/dotfiles/kitty/kitty.conf'
alias nconf='cursor ~/dotfiles/nvim'
alias v='nvim'

# kitten theme(s) writes the theme, then puts the old colors back on exit.
# ~/.local/bin/kitten reloads Kitty over its control socket after that.
# Shells that still resolve kitten to the app binary reload from here.
kitten() {
  command kitten "$@"
  local rc=$?
  case $1 in
    theme|themes) ;;
    *) return $rc ;;
  esac
  [[ $rc -eq 0 ]] || return $rc
  local bin target
  bin=${commands[kitten]:-}
  target=$(readlink "$bin" 2>/dev/null || true)
  if [[ $target == */dotfiles/bin/kitten ]]; then
    return $rc
  fi
  "$HOME/dotfiles/bin/kitten" --apply-theme-reload
  return $rc
}

# --- Prompt & plugins (packages are in Brewfile) ---
# Ensure brew is on PATH before using it (GUI apps like Kitty start with minimal env)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"                           # cursor agent, etc.
export EDITOR="nvim"
export VISUAL="nvim"
# Let Ctrl-S reach Neovim (save) instead of pausing terminal output.
stty -ixon
eval "$(starship init zsh)"                                    # prompt from starship.toml
# Plugins — only source if installed (avoids hard errors on fresh machines)
[[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
export PATH="$HOME/.cargo/bin:$PATH"  # cargo install binaries
