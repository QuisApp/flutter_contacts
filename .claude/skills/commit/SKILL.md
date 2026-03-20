---
name: commit
description: Stage and commit changes with an auto-generated message. Use when asked to commit current changes.
---

Stage and commit the current changes.

## Steps

1. Run `git status` and `git diff` to understand what changed.
2. Stage the relevant files (prefer specific files over `git add -A`). Never stage `.env` files or secrets.
3. Generate a concise commit message from the diff (1-2 sentences, focus on the "why").
4. Commit with the co-author trailer:
   ```
   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   ```
5. Show the result with `git log --oneline -1`.
