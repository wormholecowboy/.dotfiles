
# Editor
export EDITOR=nvim
export XDG_CONFIG_HOME=~/.config

# LF highlighting
# export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
# export LESS=' -R '

# Key Bindings
# bindkey -e  # emacs

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Created by Zap installer
# plug "zap-zsh/supercharge"
# plug "zap-zsh/fzf"
# plug "Aloxaf/fzf-tab"

# Load and initialise completion system
autoload -Uz compinit
compinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"


# SET OPTIONS
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# SOURCE THESE
. ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh  # make sure to source this first
. ~/scripts/dirchanger.sh
. ~/.config/lf/lfcd.sh
. ~/.config/zsh/vi-mode/zsh-vi-mode.plugin.zsh
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
. ~/.config/zsh/aliases.sh
. ~/.config/zsh/syntax-hl/zsh-syntax-highlighting.zsh
. ~/keys.sh


# PATH
export PATH="$PATH:/opt/stylua"
export PATH="$PATH:/usr/local/lf"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:/home/brian/bin"
export PATH="$PATH:/snap/bin"



# PYENV
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
