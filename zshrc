# --- Aliases ---
alias adjust="source ~/.zshrc"
alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/.zshrc'
alias kconf='cursor ~/.config/kitty/kitty.conf'

# --- Prompt & plugins (packages are in Brewfile) ---
eval "$(starship init zsh)"                                    # prompt from starship.toml
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   # command coloring
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh          # history suggestions (→ to accept)
