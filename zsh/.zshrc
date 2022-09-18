export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source $ZSH/oh-my-zsh.sh
PROMPT='%B%F{green}%4~> %f%b'
#
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git
        zsh-autosuggestions
        zsh-syntax-highlighting
        npm
        colored-man-pages
)


# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

# Aliases
alias ga="git add ."
alias gc="git commit"
alias gp="git push"
alias nrd="npm run dev"
alias lv="lvim"
alias nv='nvim'
alias cat="bat"
alias ls="lsd -al --group-dirs first"
alias ll="ls | less"

# MISC
# prompt_context() {}
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/briangildea/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/briangildea/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/briangildea/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/briangildea/google-cloud-sdk/completion.zsh.inc'; fi

# PATH
export PATH="/usr/local/opt/mongodb-community@4.4/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"
#
setopt auto_cd
cdpath=($HOME/.dotfiles/ $HOME/mycode $HOME/mynotes)
#
#
#
#
