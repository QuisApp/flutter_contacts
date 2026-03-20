---
name: branch
description: Create a temporary working branch from main. Use when starting a new task or fix.
argument-hint: [description of upcoming work]
---

Create a temporary working branch for a new task.

## Steps

1. Run `git checkout main && git pull` to ensure main is up to date.
2. Determine the branch name:
   - If `$ARGUMENTS` describes the work, derive a short kebab-case branch name from it (e.g., "fix android build" → `fix-android-build`).
   - If `$ARGUMENTS` is empty, default to `tmp-fixes`.
3. Run `git checkout -b <branch-name>`.
4. Confirm the branch was created and you're on it.
