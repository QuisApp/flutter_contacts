# Claude Skills for flutter_contacts

Project-specific skills for the development workflow. Invoke with `/<skill-name>` in Claude Code.

## Workflow

A typical release workflow looks like:

```
/branch              # create tmp-fixes branch (or /branch my-feature)
# ... make changes ...
/check               # run format, test, analyze
/run                 # run on physical devices
/commit              # stage and commit changes
/bump patch          # bump version
/commit              # commit version bump
/ship                # push, squash-merge to main, tag, cleanup
/publish             # publish to pub.dev
```

## Skills

| Skill | Description |
|-------|-------------|
| `/branch [description]` | Create a working branch (derives name from description, defaults to `tmp-fixes`) |
| `/check [format\|test\|analyze]` | Run code quality checks (all if omitted) |
| `/run [ios\|android\|macos\|all]` | Run example app on physical devices |
| `/commit` | Stage and commit with auto-generated message |
| `/bump [patch\|minor\|major]` | Bump version in pubspec.yaml + CHANGELOG (defaults to patch) |
| `/ship` | Push, squash-merge to main, tag, cleanup branch |
| `/publish [dry-run]` | Publish to pub.dev (dry-run first) |

## Setup

The `/run` skill requires a `.claude/.env` file with device IDs:

```
ANDROID_DEVICE_ID=<your-android-device-id>
IOS_DEVICE_ID=<your-ios-device-id>
```

macOS runs with `-d macos` and needs no device ID.

To find your device IDs, run `flutter devices`.
