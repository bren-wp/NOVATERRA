# NOVATERRA — Android offline game

**First Android development version: 0.0.2** · [Releases](https://github.com/bren-wp/NOVATERRA/releases)

NOVATERRA is an Android-only voxel survival game powered by the Luanti 5.17.0 native C++/OpenGL ES engine. The game includes all Lua gameplay mods, 21 textures, offline world generation and on-device saves. External game servers, accounts and hosted databases are not required.

## Android build

The `prepare-luanti.py` script packages the game and branded Android resources. The `offline_mainmenu.py` patch disables online server browsing, ContentDB access and engine update polling. The initial game is NOVATERRA and hosting controls are hidden.

The Android workflow builds a debug-signed arm64 APK and development AAB with `versionName 0.0.2` and `versionCode 20002`. The higher Android code is deliberate: older internal test builds used greater version codes than 1, and Android never allows an in-place versionCode downgrade. For each later public version, increase both the displayed version and Android versionCode monotonically.

Only a successful build with validated assets and SHA-256 sums is eligible for the **v0.0.2** GitHub prerelease. APK and AAB are development builds, not Google Play production-signed bundles. **An online upgrade of the app is not required for gameplay.**

The engine's integrated local game service may use loopback sockets. The existing Android INTERNET permission is retained until the engine's local networking has been validated without it. NOVATERRA does not depend on an external server for offline gameplay.

## Offline world selection

The bundled Android-only main menu is styled with NOVATERRA's dark green,
gold and emerald palette. The selectable world list, **continue/play**,
**create world**, **delete with confirmation**, and world configuration
remain native Luanti actions backed by existing saved worlds.
Generic server browsing, ContentDB, engine update polling and the upstream
About tab are removed from navigation. The engine's local singleplayer
runtime is preserved.

Reference images are visual targets; this build has not yet been certified
pixel-perfect or profiled on physical Android devices.

## Touch UI

The current build includes a branded splash, Android launcher icon, touch-optimized menus, pixel-heart and food HUD, crafting inventory, map and a quest journal. Primary touch-menu actions have automated Lua tests. UI visuals remain a **work in progress** compared with the supplied reference screenshots; do not represent concept artwork as actual gameplay screenshots.

## Production requirements

Physical-device launch, cold/restart, offline airplane-mode testing, landscape safe areas, gameplay stability, performance, privacy and screen-by-screen visual comparison remain necessary. Android production release signing keys and Google Play validation are not yet configured. A debug AAB must not be presented as production-signed.
