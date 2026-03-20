---
name: check
description: Run code quality checks — format, test, and analyze. Use when asked to check, lint, format, or test the codebase.
argument-hint: [format|test|analyze] (runs all if omitted)
---

Run code quality checks on the project.

## Steps

If `$ARGUMENTS` specifies a specific check (format, test, or analyze), run only that one. Otherwise run all three in order:

1. **Format**: `scripts/format.sh`
2. **Test**: `scripts/test.sh`
3. **Analyze**: `flutter analyze`

Report results after each step. If any step fails, stop and report the failure.
