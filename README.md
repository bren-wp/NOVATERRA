# NOVATERRA — Android offline game

**Current Android development version: 0.0.5** · [Releases](https://github.com/bren-wp/NOVATERRA/releases)

NOVATERRA is an Android-only voxel survival game powered by the Luanti 5.17.0 native C++/OpenGL ES engine. The game includes all Lua gameplay mods, 21 base textures plus tint-based biome materials, offline world generation and on-device saves. External game servers, accounts and hosted databases are not required.

## Android build

The `prepare-luanti.py` script packages the game and branded Android resources. The `offline_mainmenu.py` patch disables online server browsing, ContentDB access and engine update polling. The initial game is NOVATERRA and hosting controls are hidden.

The Android workflow builds a debug-signed arm64 APK and development AAB with `versionName 0.0.5` and `versionCode 20005`. The higher Android code is deliberate: older internal test builds used greater version codes than 1, and Android never allows an in-place versionCode downgrade. For each later public version, increase both the displayed version and Android versionCode monotonically.

Only a successful build with validated assets and SHA-256 sums is eligible for the **v0.0.5** GitHub prerelease. APK and AAB are development builds, not Google Play production-signed bundles. **An online upgrade of the app is not required for gameplay.**

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

## Procedural landscapes (v0.0.5)

The initial five climates are retained. Fifteen additional distinctive
climates now use NOVATERRA's original textures with independent tinting and
surface materials: alpine, frostwood, glacier, tundra, marsh, rainforest,
savanna, badlands, canyon, volcanic, twilight grove, blossom fields, crystal
valley, ocean depths and redwood. The engine generates native plants and
rare stone ruins without per-frame world modifications or network content.
Existing saved chunks are not regenerated; new content appears when
exploring *new* regions of a world.

Biome silhouettes, advanced 3D flora, foliage shaders, real shadow quality,
hand-authored settlements, 1:1 UI screenshots and final premium character
models remain unfinished; color-tinted material variants are a first pass,
not a substitute for the reference art.

## Splash-first visual parity work (v0.0.5)

The Android launch layout is rebuilt around an original scalable layered
landscape illustration (mountain peaks, rivers, forest silhouettes and a
hillside castle), the NOVATERRA crystal emblem, gold wordmark, tagline,
and an emerald extraction/progress indicator. The same native Luanti
`progressBar` and `textView` IDs are kept, and the landscape fills screens
with `centerCrop` rather than stretched pixels. The artwork is a first
implemented art direction, **not yet pixel-for-pixel identical** to the
reference image. Gameplay and main-menu screens will be compared separately.

## Selected world details (v0.0.5)

The **Detalji svijeta** action next to the native singleplayer Play button
opens a separate, touch-friendly screen. It reads genuine local `world.mt`
values (world name, game ID, map generator, seed, creative mode, damage setting)
via Luanti's `Settings`, escaping user-controlled text and treating absent
data as unknown. No fabricated timestamps, accounts or external services are
used. Inspecting a world never modifies its saved data. The underlying native
Create, Play, Configure and Delete-with-confirmation callbacks remain intact.

The visual 1:1 criterion is **still open**. Real PNGs from a physical phone
and tablet must be compared screen by screen; see
[`docs/qa/ANDROID_VISUAL_QA.md`](docs/qa/ANDROID_VISUAL_QA.md). The current
main menu does not yet feature a fully rendered 3D world preview.

## Touch UI

The current build includes a branded splash, Android launcher icon, touch-optimized menus, pixel-heart and food HUD, crafting inventory, map and a quest journal. Primary touch-menu actions have automated Lua tests. UI visuals remain a **work in progress** compared with the supplied reference screenshots; do not represent concept artwork as actual gameplay screenshots.

## Production requirements

Physical-device launch, cold/restart, offline airplane-mode testing, landscape safe areas, gameplay stability, performance, privacy and screen-by-screen visual comparison remain necessary. Android production release signing keys and Google Play validation are not yet configured. A debug AAB must not be presented as production-signed.
