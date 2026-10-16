# NOVATERRA Android release policy

Every published build must contain actual compiled Android files. Source-only tags or empty releases are not deliverables.

## Required for a development prerelease

1. NOVATERRA Lua source syntax and integration tests pass.
2. The native Android arm64 build successfully compiles the APK and AAB.
3. The APK contains the NOVATERRA game, the complete texture set, offline game selection and patched offline main menu.
4. APK and AAB pass ZIP integrity checks and SHA-256 verification.
5. Both files and `SHA256SUMS.txt` are attached to the same Android-only GitHub release.
6. The release is clearly labeled **debug/development**, not production-ready.

## Required for a production release

- Independent testing of cold start, save/load, background/foreground, crashes and controls on physical Android devices.
- Offline play verified in airplane mode, plus a network traffic audit showing no dependency on outside services.
- Pixel-by-pixel comparison of actual game captures with the requested Android references.
- Accessibility, performance, thermal and memory testing.
- Application signing with privately managed release keystore and a fresh unique `versionCode`.
- Google Play pre-launch checks, relevant policies and AAB validation.

No Windows or iOS packages should be published. Do not claim production readiness, full visual 1:1 parity or confirmed airplane-mode functionality without evidence.
