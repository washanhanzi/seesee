#!/bin/bash

# Read JSON from stdin
json=$(cat)

# Extract workspace current_dir
current_dir=$(echo "$json" | jq -r '.workspace.current_dir // .cwd // "unknown"')
dir_name=$(basename "$current_dir")

# Extract transcript path
transcript_path=$(echo "$json" | jq -r '.transcript_path // ""')

# Calculate context window size from latest assistant message
context_tokens=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  context_tokens=$(grep '"type":"assistant"' "$transcript_path" 2>/dev/null | tail -1 | jq -r '.message.usage | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' 2>/dev/null)
fi

# Format context tokens
if [ -n "$context_tokens" ] && [ "$context_tokens" != "null" ]; then
  # Format with k suffix
  if [ "$context_tokens" -ge 1000 ]; then
    context_str=$(echo "scale=1; $context_tokens / 1000" | bc)"k"
  else
    context_str="$context_tokens"
  fi

  # Calculate percentage
  percent=$(echo "scale=0; $context_tokens * 100 / 200000" | bc)

  # Color code based on usage
  if [ "$percent" -lt 50 ]; then
    context_display="🧠 ${context_str} (${percent}%)"
  elif [ "$percent" -lt 80 ]; then
    context_display="🧠 ${context_str} (${percent}%)"
  else
    context_display="⚠️  ${context_str} (${percent}%)"
  fi
else
  context_display="🧠 --"
fi

# Build status line
echo "📁 $dir_name | $context_display"

