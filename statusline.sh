#!/bin/bash

# Read JSON from stdin
json=$(cat)

# Extract workspace current_dir
current_dir=$(echo "$json" | jq -r '.workspace.current_dir // .cwd // "unknown"')
dir_name=$(basename "$current_dir")

# Extract context window info from new API
input_tokens=$(echo "$json" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$json" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$json" | jq -r '.context_window.context_window_size // 200000')
model=$(echo "$json" | jq -r '.model.display_name // "Claude"')

# Calculate total tokens and percentage
total_tokens=$((input_tokens + output_tokens))
percent=$((total_tokens * 100 / context_size))

# Format total tokens with k suffix
if [ "$total_tokens" -ge 1000 ]; then
  context_str=$(echo "scale=1; $total_tokens / 1000" | bc)"k"
else
  context_str="$total_tokens"
fi

# Color code based on usage
if [ "$percent" -lt 50 ]; then
  context_display="🧠 ${context_str} (${percent}%)"
elif [ "$percent" -lt 80 ]; then
  context_display="🧠 ${context_str} (${percent}%)"
else
  context_display="⚠️  ${context_str} (${percent}%)"
fi

# Build status line
echo "📁 $dir_name | [$model] $context_display"

