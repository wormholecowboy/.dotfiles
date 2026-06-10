# .zshenv — sourced for ALL zsh invocations (interactive, non-interactive,
# login, non-login). Keep this file fast; heavy work belongs in .zshrc.
#
# Why this file exists: non-interactive zsh shells (Claude Code's Bash tool,
# scripts, cron) don't read .zshrc, so any PATH setup there is invisible to
# them. Putting node on PATH here ensures it's available everywhere without
# paying the ~1s cost of sourcing nvm.sh.

export NVM_DIR="$HOME/.nvm"

# Resolve NVM's default alias chain (e.g. default -> lts/* -> lts/krypton ->
# v24.14.1) and prepend that version's bin to PATH. Skips sourcing nvm.sh.
() {
  local v=default i
  for i in 1 2 3 4 5; do
    [[ -f "$NVM_DIR/alias/$v" ]] || break
    v="$(<"$NVM_DIR/alias/$v")"
  done
  [[ -d "$NVM_DIR/versions/node/$v/bin" ]] && \
    export PATH="$NVM_DIR/versions/node/$v/bin:$PATH"
}
