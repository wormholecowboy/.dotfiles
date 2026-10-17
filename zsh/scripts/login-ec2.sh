#!/usr/bin/env bash
# login-ec2 — open an SSM session into an EC2 instance, assuming you are
# already logged in to AWS (via awsl). If no instance id is given, lists
# running instances to pick from.
login-ec2() {
  local instance_id=""
  local arg

  for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
      cat <<EOM
Usage: login-ec2 [instance-id]

Requires an active AWS session (run awsl first). If instance-id is
omitted, you'll be shown a list of running instances to pick from.

Examples:
  login-ec2                      Pick an instance from the running list
  login-ec2 i-0123456789abcdef0  Connect directly to that instance
EOM
      return 0
    elif [[ "$arg" =~ ^i-[0-9a-f]+$ ]]; then
      instance_id="$arg"
    else
      echo "Unrecognized argument: ${arg}" >&2
      return 1
    fi
  done

  if ! command -v aws >/dev/null 2>&1; then
    echo "aws CLI isn't on your PATH." >&2
    return 1
  fi

  if ! command -v session-manager-plugin >/dev/null 2>&1; then
    echo "The Session Manager plugin isn't installed, it's required for SSM sessions." >&2
    echo "Install with: brew install --cask session-manager-plugin" >&2
    return 1
  fi

  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "You aren't logged in to AWS (or your session expired). Run: awsl" >&2
    return 1
  fi

  if [[ -z "$instance_id" ]]; then
    echo "Fetching running instances..."
    local -a labels=()
    local id name state

    while IFS=$'\t' read -r id name state; do
      [[ -z "$id" ]] && continue
      if [[ -n "$name" && "$name" != "None" ]]; then
        labels+=("${id}  (${name}) [${state}]")
      else
        labels+=("${id}  [${state}]")
      fi
    done < <(aws ec2 describe-instances \
      --filters "Name=instance-state-name,Values=running" \
      --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`]|[0].Value, State.Name]' \
      --output text 2>/dev/null)

    if [[ ${#labels[@]} -eq 0 ]]; then
      echo "No running instances found." >&2
      return 1
    fi

    local chosen
    if command -v fzf >/dev/null 2>&1; then
      chosen="$(printf '%s\n' "${labels[@]}" | fzf \
        --prompt="instance> " \
        --header="Select an instance (Esc to cancel)" \
        --height=40% --reverse)"
      if [[ -z "$chosen" ]]; then
        echo "No instance was selected, aborting." >&2
        return 1
      fi
    else
      echo "Select an instance:"
      local PS3="Instance number: "
      select chosen in "${labels[@]}"; do
        [[ -n "$chosen" ]] && break
        echo "Not a valid selection. Try again, or Ctrl+C to cancel." >&2
      done
    fi

    instance_id="${chosen%% *}"
  fi

  if [[ -z "$instance_id" ]]; then
    echo "No instance was selected, aborting." >&2
    return 1
  fi

  local current_state
  current_state="$(aws ec2 describe-instances \
    --instance-ids "$instance_id" \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text 2>/dev/null)"

  if [[ -n "$current_state" && "$current_state" != "None" && "$current_state" != "running" ]]; then
    echo "Warning: instance ${instance_id} is currently '${current_state}', not 'running'." >&2
  fi

  echo "Starting SSM session into ${instance_id}..."
  aws ssm start-session --target "${instance_id}"
}

login-ec2 "$@"
