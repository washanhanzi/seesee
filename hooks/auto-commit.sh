#!/bin/bash

# Auto-commit hook for Claude Code
# Commits changes after file modifications with a WIP message

# Change to the git repository directory
cd "$CLAUDE_PROJECT_DIR" || exit 0

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
fi

# Check if there are any changes to commit
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    exit 0
fi

# Get a short description from recent file changes
# This will list the modified files and create a simple description
description=$(git status --short | head -5 | awk '{print $2}' | xargs basename -a | paste -sd ", " -)

# If description is empty, fall back to a generic message
if [ -z "$description" ]; then
    description="code changes"
fi

# Truncate description if too long
if [ ${#description} -gt 60 ]; then
    description="${description:0:57}..."
fi

# Stage all changes
git add -A

# Create commit with WIP message
git commit -m "wip: $description" --no-verify > /dev/null 2>&1

exit 0
