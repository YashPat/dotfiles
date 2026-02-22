# --- PATH (only add what you need; system + Homebrew already set the rest) ---
export PATH="$HOME/go/bin:$PATH"                    # Go binaries (go install)
export PATH="/opt/homebrew/opt/bison/bin:$PATH"      # Homebrew bison (keg-only)

# --- Node (nvm) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Aliases ---
alias adjust="source ~/.zshrc"
alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/.zshrc'
alias kconf='cursor ~/.config/kitty/kitty.conf'

# --- Prompt & plugins (brew install zsh-syntax-highlighting zsh-autosuggestions) ---
eval "$(starship init zsh)"
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
