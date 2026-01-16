---
name: oracle
description: Query Google's Gemini CLI and OpenAI's Codex CLI in parallel and report back findings. This skill should be used when the user explicitly invokes /oracle, asks to query Gemini, wants a second opinion from another AI, or wants to compare perspectives on a question.
---

# Oracle

## Overview

This skill invokes both the Gemini CLI and Codex CLI in parallel to send queries to Google's Gemini and OpenAI's models, then summarizes and reports back their findings. It provides a way to get multiple AI perspectives on any question or topic.

## When to Use

- User explicitly invokes `/oracle` followed by a query
- User asks to "ask Gemini" or "query other AIs" about something
- User wants to compare Claude's answer with other AI perspectives
- User requests a "second opinion" from other AI models

## Workflow

### Step 1: Extract the Query

Identify the user's question or query that should be sent to both AIs. If the user invokes `/oracle what is rust?`, the query is "what is rust?".

### Step 2: Execute Queries in Parallel

Launch TWO Task agents in parallel using `subagent_type=Bash`:

**Agent 1 - Gemini:**
```bash
/home/frank/.claude/skills/oracle/scripts/query_gemini.sh "the user query here"
```

**Agent 2 - Codex:**
```bash
/home/frank/.claude/skills/oracle/scripts/query_codex.sh "the user query here"
```

IMPORTANT: Both agents MUST be launched in a single message with multiple Task tool calls to run them in parallel.

### Step 3: Summarize and Report Findings

Once both agents complete, present the findings to the user:

1. **Gemini's Response**: Present the key points from Gemini's answer
2. **Codex's Response**: Present the key points from Codex's answer
3. **Summary**: Provide a brief synthesis highlighting:
   - Points where both AIs agree
   - Any notable differences in perspective
   - Key insights from each response

## Example Usage

**User**: /oracle What are the benefits of using Rust for web services?

**Expected workflow**:
1. Extract query: "What are the benefits of using Rust for web services?"
2. Launch two Task agents in parallel:
   - Task 1: Run `query_gemini.sh "What are the benefits of using Rust for web services?"`
   - Task 2: Run `query_codex.sh "What are the benefits of using Rust for web services?"`
3. Wait for both to complete
4. Summarize and report both responses with attribution

## Scripts

### scripts/query_gemini.sh

Executes a query against the Gemini CLI and returns the response in text format.

**Usage**: `query_gemini.sh "your question here"`

### scripts/query_codex.sh

Executes a query against the Codex CLI and returns the response.

**Usage**: `query_codex.sh "your question here"`
