# NOVATERRA — Android offline game

NOVATERRA is an Android-only voxel survival game powered by the Luanti 5.17.0 native C++/OpenGL ES engine. The game includes all Lua gameplay mods, 21 textures, offline world generation and on-device saves. External game servers, accounts and hosted databases are not required.

## Android build

The `android/prepare-luanti.py` script packages the game and branded Android resources. The `android/offline_mainmenu.py` patch disables online server browsing, ContentDB access and engine update polling. The initial game is NOVATERRA and hosting controls are hidden.

The GitHub Android workflow creates a debug-signed arm64 APK and a development AAB, and verifies included assets and SHA-256 checksums. The Android release workflow is configured to publish those packages after successful checks.

The engine's integrated local game service may use loopback sockets. The existing Android INTERNET permission is retained until the engine's local networking has been validated without it. NOVATERRA does not depend on an external server for offline gameplay.

## Touch UI

The app includes a branded splash, Android launcher icon, responsive in-game menu, pixel-heart and food HUD, crafting inventory, map and a quest journal. All primary menu actions have Lua tests.

## Production requirements

Physical-device launch, cold/restart, offline airplane-mode testing, landscape safe areas, gameplay stability, performance, privacy and screen-by-screen visual comparison remain necessary. Android production release signing keys and Google Play validation are not yet configured. A debug AAB must not be presented as production-signed.
