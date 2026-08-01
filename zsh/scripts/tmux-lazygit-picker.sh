#!/usr/bin/env sh
# fzf picker over git worktrees/repos, opens the choice in lazygit.
# Handles the bare-repo + worktrees layout: lists each worktree dir and
# skips the .bare container root (dir that holds a .bare/ alongside its .git).

roots="$HOME/things/myc $HOME/.dotfiles"

sel=$(fd -Hg '.git' $roots --max-depth 4 \
        -x sh -c 'd=$(dirname "$1"); [ -d "$d/.bare" ] && exit 0; echo "$d"' _ {} \
      | sort \
      | fzf --reverse --header='lazygit worktree')

[ -n "$sel" ] && lazygit -p "$sel"
