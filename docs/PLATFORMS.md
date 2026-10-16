# Android-only platform architecture

NOVATERRA is an **Android-only, offline, native-engine** voxel game.

## Runtime

The Android APK embeds the Luanti 5.17.0 C++ and OpenGL ES engine plus the complete NOVATERRA Lua game, its mods and assets. The engine runs the singleplayer world locally. No external multiplayer server, user account, managed database or hosted game API is required.

The Android game selector shows only locally saved worlds. Public server discovery, ContentDB and engine update polling are hidden/disabled in the packaged Android menu. World files, settings and inventories live in the app's private data area.

The Android manifest currently retains its upstream INTERNET permission because the engine uses local network sockets internally. This does **not** mean a remote backend is required. Removing or restricting this permission must be validated against world-creation and loopback behavior on a real Android device.

## Build

`android/prepare-luanti.py` brands the upstream engine, bundles all 21 PNG assets and patches the engine menu into offline mode. `.github/workflows/android-game.yml` compiles arm64 APK and development AAB. `.github/workflows/android-release.yml` publishes their verified packages.

## Scope

Windows and iOS sources were removed. Gameplay and assets live under `games/novaterra/`. Native Android functionality and in-game UI continue to be improved in-place. Production signing, network privacy audit and physical-device QA are required before store distribution.
