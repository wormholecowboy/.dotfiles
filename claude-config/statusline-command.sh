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

# Model name (cyan)
output+=$(printf '\033[2;36m[%s]\033[0m ' "$model_name")

# Directory path (orange/yellow color: #FFA825)
# Using dimmed colors for status line
dir_display="$cwd"
output+=$(printf '\033[2;38;2;255;168;37m%s\033[0m ' "$dir_display")

# Git branch and status (if in a git repo)
if git rev-parse --git-dir > /dev/null 2>&1; then
  # Get branch name
  branch=$(git branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git rev-parse --short HEAD 2>/dev/null)
  fi
  
  if [ -n "$branch" ]; then
    # Git branch with symbol in green
    output+=$(printf '\033[2;1;32m[\033[0m')
    output+=$(printf '\033[2;1;32m\ue725 %s\033[0m' "$branch")
    output+=$(printf '\033[2;1;32m]\033[0m ')
    
    # Git status
    git_status=""
    
    # Check for various git states (skip optional locks)
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    
    # Ahead/behind
    ahead_behind=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
    if [ -n "$ahead_behind" ]; then
      behind=$(echo "$ahead_behind" | awk '{print $1}')
      ahead=$(echo "$ahead_behind" | awk '{print $2}')
      
      if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
        git_status+="⇕⇡😵${ahead}⇣${behind}"
      elif [ "$ahead" -gt 0 ]; then
        git_status+="⇡🏎💨${ahead}"
      elif [ "$behind" -gt 0 ]; then
        git_status+="⇣😰${behind}"
      fi
    fi
    
    [ "$untracked" -gt 0 ] && git_status+="🤷"
    [ "$modified" -gt 0 ] && git_status+="📝"
    [ "$staged" -gt 0 ] && git_status+=$(printf '\033[2;32m++(%s)\033[0m' "$staged")
    
    if [ -n "$git_status" ]; then
      output+="$git_status "
    fi
  fi
fi

# Context window usage (magenta)
if [ "$context_size" != "0" ] && [ "$context_size" != "null" ] && [ "$current_usage" != "null" ]; then
  input_tokens=$(echo "$current_usage" | jq -r '.input_tokens // 0')
  cache_creation=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0')
  cache_read=$(echo "$current_usage" | jq -r '.cache_read_input_tokens // 0')
  total_tokens=$((input_tokens + cache_creation + cache_read))
  percent_used=$((total_tokens * 100 / context_size))
  # Format token counts in K (thousands)
  tokens_k=$(awk "BEGIN {printf \"%.1f\", $total_tokens/1000}")
  context_k=$(awk "BEGIN {printf \"%.0f\", $context_size/1000}")
  output+=$(printf '\033[2;35m⧗%sk/%sk (%s%%)\033[0m ' "$tokens_k" "$context_k" "$percent_used")
fi

# Code change stats (green for added, red for removed)
if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
  output+=$(printf '\033[2;32m+%s\033[0m' "$lines_added")
  output+=$(printf '\033[2;31m-%s\033[0m ' "$lines_removed")
fi

# Print the final status line
echo -n "$output"
