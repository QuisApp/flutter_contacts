---
name: publish
description: Publish the package to pub.dev. Runs dry-run first, then publishes on confirmation.
argument-hint: [dry-run] (runs dry-run only if specified)
---

Publish the package to pub.dev.

## Steps

1. Run `flutter pub publish --dry-run` and show the output.
2. If `$ARGUMENTS` is "dry-run", stop here.
3. Otherwise, ask the user to confirm before proceeding.
4. On confirmation, run `flutter pub publish --force` (non-interactive).
5. Report success or failure.
