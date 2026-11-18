# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository using GNU Stow-style structure. Each top-level directory contains configs that get symlinked to `~/.config/` or `~/`.

## Structure

```
zsh/           # Shell config (.zshrc, aliases, plugins, custom prompt)
tmux/          # Terminal multiplexer (.tmux.conf)
nvim/          # Neovim config (Lua-based, Lazy plugin manager)
lf/            # File manager
ghostty/       # Terminal emulator
claude/        # Claude Code config: agents, skills, settings (~/.claude links here)
ai/            # AI prompts, rules, and templates
```

## Key Files

- `zsh/.zshrc` - Main shell config with deferred NVM activation and cached init scripts
- `zsh/.config/zsh/prompt.zsh` - Custom zsh prompt (path + git branch)
- `zsh/.config/zsh/aliases.sh` - Shell aliases
- `tmux/.tmux.conf` - Tmux config with fzf session management
- `decisions.md` - Architectural decisions log (update when making significant changes)

## Zsh Performance Optimizations

The shell uses several optimizations to reduce startup time:

1. **Deferred NVM activation** - `nvm.sh` is sourced with `--no-use`; `zsh/.zshenv` puts node on PATH
2. **Cached zoxide init** - zoxide init output is cached
3. **Custom prompt** - Native zsh prompt using `vcs_info`

After upgrading zoxide, regenerate cache:
```bash
zoxide init zsh > ~/.config/zsh/zoxide.zsh
```

## Working with This Repo

- Test shell changes with `time zsh -i -c exit`
- Log significant decisions in `decisions.md` with date and rationale
- Claude Code config lives in `claude/.claude/` (agents, skills); `~/.claude/` symlinks into it

## Commit Message Format

Use conventional commits with a scope matching the top-level directory:

```
feat(nvim): add buffer view preservation
fix(zsh): correct NVM lazy load path
chore(tmux): update keybind prefix
```
