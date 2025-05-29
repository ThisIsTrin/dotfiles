export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git z sudo zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Prompt configuration
export DEFAULT_USER=$(whoami)  # Cleaner prompt if using agnoster

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# History options
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Enable auto-suggestions and syntax highlighting
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
