#!/bin/bash
# Query Gemini CLI with a prompt and return the response
# Usage: query_gemini.sh "your question here"

set -e

if [ -z "$1" ]; then
    echo "Error: No query provided"
    echo "Usage: query_gemini.sh \"your question here\""
    exit 1
fi

# Run gemini with the provided prompt in non-interactive mode
# Using text output format for clean response
gemini -o text "$@"
