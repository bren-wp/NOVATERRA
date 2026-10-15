# NOVATERRA — Android

NOVATERRA uses the **Luanti 5.17.0 native C++/OpenGL ES engine** with shared Lua game modules. The Android package is built by Gradle from a pinned upstream engine checkout, with the complete game and its 17 original textures bundled at build time.

## Android development packages

- **APK (arm64)** — debug-signed, intended for direct installation and device testing.
- **AAB** — debug development bundle, **not** signed with a Google Play production key.
- Package name: `com.brendigo.novaterra`; development version code: `12001`.
- Build workflow: [Android game build](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml).

The build verifies the Android package identity, embedded `games/novaterra` source, RPG and creature modules, original textures, Android configuration and native arm64 libraries. APK/AAB checksums are saved in `SHA256SUMS.txt`.

## Touch and mobile experience

NOVATERRA uses the engine's touch controls, rather than emulating a keyboard or embedding a web app. A mobile configuration is included in the game's Android asset archive. The shared Lua interface exposes a survival HUD, inventory/crafting, world map, settings, and the RPG quest journal. The game currently opens using the Luanti engine's native game-selection UI.

**Kotlin decision:** Kotlin is appropriate for future Android-specific onboarding, permissions, Play Billing (if ever required), and platform services. It is **not** a substitute for the C++ 3D engine. Avoid introducing a second activity/UI layer until its engine integration and lifecycle are tested.

## Production release gates

The following remain required before claiming that Android is fully complete:

1. Install APK on physical Android devices and run launch/exit/relaunch tests.
2. Create, save and reload a world; test hunger, mobs, furnace, crafting, quest progression and multiplayer.
3. Verify touch targets, gesture conflicts, font scaling, safe areas, landscape/portrait behavior, frame pacing and thermal performance.
4. Replace temporary voxel creature visuals and bring splash, main menu, HUD, inventory, buttons and all game screens to the owner's reference designs **screen by screen**.
5. Set up a secure production signing key, bump unique `versionCode`, build a **release** AAB and run Google Play pre-launch and policy checks.

CI success proves that binaries were compiled and packaged; it does not prove visual parity or physical-device compatibility. Do not describe a debug-signed AAB as a store-ready release.
