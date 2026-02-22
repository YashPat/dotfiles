# --- Aliases ---
alias adjust="source ~/.zshrc"
alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/.zshrc'
alias kconf='cursor ~/.config/kitty/kitty.conf'

# --- Prompt & plugins (packages are in Brewfile) ---
# Ensure brew is on PATH before using it (GUI apps like Kitty start with minimal env)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
eval "$(starship init zsh)"                                    # prompt from starship.toml
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   # command coloring
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh          # history suggestions (→ to accept)
