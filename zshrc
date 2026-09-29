# --- Aliases ---
alias adjust="source ~/.zshrc"
alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/.zshrc'
alias kconf='cursor ~/dotfiles/kitty/kitty.conf'
alias nconf='cursor ~/dotfiles/nvim'
alias v='nvim'

# kitten themes saves the theme, then signals Kitty with SIGUSR1.
# That signal no longer reloads this Kitty, so apply the file over the control socket.
kitten() {
  command kitten "$@"
  local rc=$?
  [[ $rc -eq 0 && $1 == themes ]] || return $rc
  local sock="${KITTY_LISTEN_ON:-}"
  if [[ -z $sock ]]; then
    local matches=(${HOME}/.cache/kitty/control-*(N))
    if (( ${#matches} == 1 )); then
      sock="unix:${matches[1]}"
    fi
  fi
  if [[ -n $sock ]]; then
    command kitten @ --to "$sock" load-config >/dev/null
  fi
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
