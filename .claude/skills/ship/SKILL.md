---
name: ship
description: Ship the current branch — push, squash-merge to main via PR, tag, and clean up. Use when ready to merge and release.
---

Ship the current branch to main.

## Prerequisites

- Must NOT be on `main` branch already. If on main, abort with a message.
- Working tree should be clean. If not, warn the user.

## Steps

1. Get the current branch name.
2. Push the branch to origin: `git push -u origin <branch>`.
3. Create a PR targeting main using `gh pr create`. Use the squashed commit subjects as the PR body.
4. Squash-merge the PR: `gh pr merge --squash --delete-branch`.
5. Checkout main and pull: `git checkout main && git pull`.
6. Delete the local branch if it still exists: `git branch -d <branch>`.
7. Read the version from `pubspec.yaml` and prefix with `v` for the tag.
8. Create and push the tag: `git tag -a <tag> -m "<tag>" && git push origin <tag>`.
9. Confirm completion with a summary.
