# Custom zsh prompt (replaces starship)
# Colors: path=#FFA825 (orange), git branch=green, brackets=white

autoload -Uz vcs_info
precmd() { vcs_info }

# Git branch format: [icon branch] in green with white brackets
zstyle ':vcs_info:git:*' formats '%F{white}[%F{green}%b%F{white}]%f '
zstyle ':vcs_info:*' enable git

# Enable prompt substitution
setopt PROMPT_SUBST

# Blank line before prompt
precmd() {
  vcs_info
  print
}

# Prompt: path (orange) + git branch + newline + prompt char
# %~ = path, %(?..X) = show X on error
PROMPT='%F{#FFA825}%5~%f ${vcs_info_msg_0_}
%(?.%F{white}❯%f.%F{red}X%f) '
