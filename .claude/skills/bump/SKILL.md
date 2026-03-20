---
name: bump
description: Bump the package version in pubspec.yaml and add a CHANGELOG entry. Defaults to patch bump.
argument-hint: [patch|minor|major] (defaults to patch)
---

Bump the package version and update the changelog.

## Steps

1. Read the current version from `pubspec.yaml`.
2. Parse the version as `major.minor.patch`.
3. Determine bump type from `$ARGUMENTS` (patch, minor, or major). Default to **patch** if not specified.
4. Compute the new version:
   - **patch**: increment patch (e.g., 2.0.1 → 2.0.2)
   - **minor**: increment minor, reset patch (e.g., 2.0.1 → 2.1.0)
   - **major**: increment major, reset minor and patch (e.g., 2.0.1 → 3.0.0)
5. Update `version:` in `pubspec.yaml`.
6. Add a new section at the top of `CHANGELOG.md` with the new version number.
7. Generate changelog entries from recent commits since the last tag.
8. Regenerate API docs: `scripts/doc.sh`
9. Open the docs: `open doc/api/index.html`
10. Do NOT commit — let the user review and commit separately.
