# Release policy

Every development milestone should result in a new, uniquely versioned GitHub release **only after** the source is complete enough to package and the release has real artifacts.

Required checks:
1. All required game files and textures present.
2. Lua syntax and automated tests pass.
3. Windows executable starts on Windows and creates/loads a world.
4. Android APK launches on an Android device; AAB is validated.
5. UI screenshots are compared with supplied references.
6. SHA-256 checksums and changelog accompany artifacts.
7. Release notes distinguish verified functionality from incomplete features.

**Never** label a commit, placeholder file, or untested script as a verified Windows/Android binary.
