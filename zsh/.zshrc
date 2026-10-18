export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ========================
# ||  Oh My Zsh config  ||
# ========================

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="agnoster"
ZSH_THEME="eastwood"

zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

ENABLE_CORRECTION="true"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git kube-ps1 aws zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# ========================
# || User configuration ||
# ========================
# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias gp="git pull"
alias gs="git status -sb"
alias gl="git log --oneline -n 20"
alias l="ls -la"
alias ll="ls -lh"
alias k="kubectl"
alias tf="terraform"

export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# >>> Magnitude CLI PATH >>>
case "$PATH" in
  "$HOME/.magnitude/bin"|"$HOME/.magnitude/bin":*) ;;
  *) export PATH="$HOME/.magnitude/bin:$PATH" ;;
esac
# <<< Magnitude CLI PATH <<<

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
