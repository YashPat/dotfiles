alias swiftCode="cd documents/code/swift"
alias pythonCode="cd documents/code/python"
alias adjust="source ~/.zshrc"
alias rs="bash runSwift.sh $1"
alias rp="bash runPython.sh $1"
export PATH=/usr/local/bin:/usr/local/bin:/Library/Frameworks/Python.framework/Versions/3.9/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/opt/homebrew/bin

alias ls='eza --icons --grid --group-directories-first'
alias ll='eza --icons --long --header --git'
alias tree='eza --icons --tree'
alias zconf='cursor ~/.zshrc'
alias kconf='cursor ~/.config/kitty/kitty.conf'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by Windsurf
export PATH="/Users/yashpatil/.codeium/windsurf/bin:$PATH"
export PATH="/opt/homebrew/opt/bison/bin:$PATH"

eval "$(starship init zsh)"
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/Users/yashpatil/go/bin:$PATH"
