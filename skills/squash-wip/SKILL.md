---
name: squash-wip
description: Squash all commits starting with "wip:" on the current branch into a single commit with a proper conventional commit message. This skill should be used when the user wants to clean up work-in-progress commits before pushing or creating a PR.
---

# Squash WIP Commits

This skill squashes all consecutive "wip:" commits from HEAD into a single well-formatted commit.

## Workflow

### Step 1: Identify WIP Commits

Run git log to find all commits starting with "wip:":

```bash
git log --oneline -20
```

Identify:
- The number of consecutive "wip:" commits from HEAD
- The base commit (the commit immediately before the first "wip:" commit)

### Step 2: Squash Using Soft Reset

Reset to the base commit while keeping all changes staged:

```bash
git reset --soft <base-commit-hash>
```

### Step 3: Analyze Changes

Review what was changed to determine the appropriate commit message:

```bash
git diff --staged --stat
```

For more detail on specific files if needed:

```bash
git diff --staged -- <file-path> | head -100
```

### Step 4: Determine Commit Type

Based on the changes, select the appropriate conventional commit type:
- `feat:` - New feature or functionality
- `fix:` - Bug fix
- `refactor:` - Code restructuring without behavior change
- `docs:` - Documentation only
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### Step 5: Commit with Proper Message

Create a commit with a title and descriptive body:

```bash
git commit -m "$(cat <<'EOF'
<type>: <concise title>

- <bullet point describing a key change>
- <bullet point describing another change>
- <additional details as needed>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Commit Message Guidelines

- **Title**: Use imperative mood, max 50 characters (e.g., "add user authentication")
- **Body**: Explain what changed and why, use bullet points for multiple changes
- **Keep it concise**: Focus on the "what" and "why", not the "how"

## Recovery

If something goes wrong, use `git reflog` to find the previous HEAD and reset back:

```bash
git reflog
git reset --hard <previous-head>
```
