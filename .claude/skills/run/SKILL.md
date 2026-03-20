---
name: run
description: Run the example app on physical devices. Requires .claude/.env with device IDs. Use when asked to run on devices.
argument-hint: [ios|android|macos|all] (defaults to all)
---

Run the example app on physical devices. Device IDs are configured in `.claude/.env`.

## Environment

Load device IDs from `.claude/.env`:
- `ANDROID_DEVICE_ID` — Android device
- `IOS_DEVICE_ID` — iOS device
- macOS needs no device ID

The shell aliases `i7` (iOS), `a` (Android), and `m` (macOS) may be available but don't work in non-interactive shells. Use `flutter run -d <device-id>` directly instead.

## Steps

1. Read `.claude/.env` to get device IDs.
2. Determine which devices to target from `$ARGUMENTS` (ios, android, macos, or all). Default is all.
3. `cd example` before running.
4. Run each device in the background:
   - **Android**: `flutter run -d $ANDROID_DEVICE_ID`
   - **iOS**: `flutter run -d $IOS_DEVICE_ID`
   - **macOS**: `flutter run -d macos`
5. Report build/launch results.
