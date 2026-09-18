#!/usr/bin/env bash
# herdr-workspace-status — print the focused herdr workspace label for a
# tab_bar_right command entry. Herdr has no {workspace} token for the tab
# bar, so this polls the socket API instead.
set -euo pipefail

herdr workspace list 2>/dev/null \
  | jq -r '.result.workspaces[] | select(.focused) | .label' 2>/dev/null \
  | head -n1
