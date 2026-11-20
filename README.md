# ios-demo

SwiftUI demo app built end-to-end on a GitHub Actions macOS runner (no local Mac).

- `project.yml` -> XcodeGen generates the .xcodeproj on the runner
- `.github/workflows/ios.yml` -> builds simulator app, builds unsigned device .ipa,
  boots a simulator, launches the app and captures `screenshot.png`
- Artifacts: `screenshot.png`, `Demo-unsigned.ipa`
