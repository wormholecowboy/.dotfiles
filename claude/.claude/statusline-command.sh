#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
current_usage=$(echo "$input" | jq -r '.context_window.current_usage')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Change to the working directory
cd "$cwd" 2>/dev/null || { echo "$cwd"; exit 0; }

# Build the status line similar to Starship
output=""

# Directory path (orange: #FFA825)
# Show last 5 directories (matches zsh %5~)
dir_display=$(echo "$cwd" | sed "s|^$HOME|~|" | awk -F'/' '{n=NF; start=(n>5)?n-4:1; for(i=start;i<=n;i++) printf "%s%s", (i>start?"/":""), $i}')
output+=$(printf '\033[38;2;255;168;37m%s\033[0m ' "$dir_display")

# Git branch (if in a git repo)
if git rev-parse --git-dir > /dev/null 2>&1; then
  # Get branch name
  branch=$(git branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git rev-parse --short HEAD 2>/dev/null)
  fi

  if [ -n "$branch" ]; then
    # Git branch: white brackets, green branch (matches zsh prompt)
    output+=$(printf '\033[37m[\033[32m%s\033[37m]\033[0m' "$branch")
  fi
fi
output+=$'\n'

# Model name (cyan)
output+=$(printf '\033[2;36m[%s]\033[0m ' "$model_name")

# Context window usage with color-coded bar
if [ "$context_size" != "0" ] && [ "$context_size" != "null" ] && [ -n "$context_size" ] && [ "$current_usage" != "null" ] && [ -n "$current_usage" ]; then
  input_tokens=$(echo "$current_usage" | jq -r '.input_tokens // 0')
  cache_creation=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0')
  cache_read=$(echo "$current_usage" | jq -r '.cache_read_input_tokens // 0')
  total_tokens=$((input_tokens + cache_creation + cache_read))
  if [ "$context_size" -gt 0 ] 2>/dev/null; then
    percent_used=$((total_tokens * 100 / context_size))
  else
    percent_used=0
  fi
  # Format token counts in K (thousands)
  tokens_k=$(awk "BEGIN {printf \"%.1f\", $total_tokens/1000}")
  context_k=$(awk "BEGIN {printf \"%.0f\", $context_size/1000}")
  # Color based on usage: green < 40%, yellow 40-54%, red >= 55%
  if [ "$percent_used" -ge 55 ]; then
    bar_color='\033[31m'
  elif [ "$percent_used" -ge 40 ]; then
    bar_color='\033[33m'
  else
    bar_color='\033[38;2;0;200;80m'
  fi
  # Build 10-segment bar
  filled=$((percent_used / 10))
  empty=$((10 - filled))
  bar=$(printf "%${filled}s" | tr ' ' '█')$(printf "%${empty}s" | tr ' ' '░')
  output+=$(printf '%s%% %b%s\033[0m %sk/%sk ' "$percent_used" "$bar_color" "$bar" "$tokens_k" "$context_k")
fi

# Code change stats (green for added, red for removed)
if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
  output+=$(printf '\033[2;32m+%s\033[0m' "$lines_added")
  output+=$(printf '\033[2;31m-%s\033[0m ' "$lines_removed")
fi

# Print the final status line
echo -n "$output"
