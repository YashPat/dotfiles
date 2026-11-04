# --- Aliases ---
alias adjust="source ~/.zshrc"
alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/dotfiles/zshrc'
alias kconf='cursor ~/dotfiles/kitty/kitty.conf'
alias nconf='cursor ~/dotfiles/nvim'
alias v='nvim'

# --- PATH (GUI apps like Kitty start with a minimal env) ---
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"  # kitten wrapper, kshader, wall, cargo installs

export EDITOR="nvim"
export VISUAL="nvim"
# Let Ctrl-S reach Neovim (save) instead of pausing terminal output.
stty -ixon

# --- Prompt & plugins (packages are in Brewfile) ---
eval "$(starship init zsh)"  # prompt from starship.toml
for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
  f="$HOMEBREW_PREFIX/share/$plugin/$plugin.zsh"
  [[ -f $f ]] && source "$f"
done
unset plugin f
