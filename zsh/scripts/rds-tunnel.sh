#!/usr/bin/env bash
# rds-tunnel — open SSM port-forwarding tunnels to RDS through the EC2
# bastion. Pick one or more databases in fzf (Tab to multi-select).
# Tunnels run as background jobs in this shell; Ctrl+C closes them all.
# Requires an active AWS session (run awsl first).

BASTION_INSTANCE_ID="i-09c35b10cc0f38b96"

# Format: alias|remote-host|remote-port|local-port
DATABASES=(
  "general|aurora-cluster-general-digms-database.cluster-cjgqm4um8mia.us-west-2.rds.amazonaws.com|3306|3308"
  "stage-general|aurora-cluster-stage-general-digms-database.cluster-cjgqm4um8mia.us-west-2.rds.amazonaws.com|3306|3307"
)

rds-tunnel() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
      cat <<EOM
Usage: rds-tunnel

Opens SSM port-forwarding tunnels to RDS databases through the bastion
(${BASTION_INSTANCE_ID}). Requires an active AWS session (run awsl
first). Pick databases in the fzf list: Tab to select several, Enter to
confirm. Tunnels run as background jobs here and Ctrl+C closes them all.
EOM
      return 0
    fi
  done

  local required_cmd
  for required_cmd in aws fzf session-manager-plugin; do
    if ! command -v "$required_cmd" >/dev/null 2>&1; then
      echo "${required_cmd} isn't on your PATH." >&2
      case "$required_cmd" in
        fzf) echo "Install with: brew install fzf" >&2 ;;
        session-manager-plugin) echo "Install with: brew install --cask session-manager-plugin" >&2 ;;
      esac
      return 1
    fi
  done

  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "You aren't logged in to AWS (or your session expired). Run: awsl" >&2
    return 1
  fi

  local entry chosen
  chosen="$(
    for entry in "${DATABASES[@]}"; do
      IFS='|' read -r db_alias host remote_port local_port <<<"$entry"
      printf '%-20s localhost:%-6s -> %s:%s\n' "$db_alias" "$local_port" "$host" "$remote_port"
    done | fzf --multi --prompt='RDS tunnel> ' --header='Tab: multi-select, Enter: open tunnels'
  )"

  if [[ -z "$chosen" ]]; then
    echo "Nothing selected." >&2
    return 1
  fi

  local -a tunnel_pids=()
  local line selected_alias db_alias host remote_port local_port params
  while IFS= read -r line; do
    selected_alias="${line%% *}"
    for entry in "${DATABASES[@]}"; do
      IFS='|' read -r db_alias host remote_port local_port <<<"$entry"
      [[ "$db_alias" == "$selected_alias" ]] || continue

      if lsof -i ":${local_port}" >/dev/null 2>&1; then
        echo "Port ${local_port} is already in use, skipping ${db_alias}." >&2
        continue
      fi

      params="$(printf '{"host":["%s"],"portNumber":["%s"],"localPortNumber":["%s"]}' \
        "$host" "$remote_port" "$local_port")"

      aws ssm start-session \
        --target "${BASTION_INSTANCE_ID}" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "$params" &
      tunnel_pids+=($!)
      echo "Tunnel to ${db_alias} on localhost:${local_port} (pid $!)"
    done
  done <<<"$chosen"

  if [[ ${#tunnel_pids[@]} -gt 0 ]]; then
    echo "Tunnels are up. Ctrl+C closes them all."
    trap 'kill "${tunnel_pids[@]}" 2>/dev/null' INT TERM
    wait
    trap - INT TERM
  fi
}

rds-tunnel "$@"
