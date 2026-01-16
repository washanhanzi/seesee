#!/bin/bash
# Query Codex CLI with a prompt and return the response
# Usage: query_codex.sh "your question here"

set -e

if [ -z "$1" ]; then
    echo "Error: No query provided"
    echo "Usage: query_codex.sh \"your question here\""
    exit 1
fi

# Run codex exec with the provided prompt in non-interactive mode
# Using --skip-git-repo-check to allow running outside git repos
codex exec --skip-git-repo-check "$@"
