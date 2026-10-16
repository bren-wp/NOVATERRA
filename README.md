# NOVATERRA — Android offline game

**Current Android development version: 0.0.8** · [Releases](https://github.com/bren-wp/NOVATERRA/releases)

NOVATERRA is an Android-only voxel survival game powered by the Luanti 5.17.0 native C++/OpenGL ES engine. The game includes all Lua gameplay mods, 21 base textures plus tint-based biome materials, offline world generation and on-device saves. External game servers, accounts and hosted databases are not required.

## Android build

The `prepare-luanti.py` script packages the game and branded Android resources. The `offline_mainmenu.py` patch disables online server browsing, ContentDB access and engine update polling. The initial game is NOVATERRA and hosting controls are hidden.

The Android workflow builds a debug-signed arm64 APK and development AAB with `versionName 0.0.8` and `versionCode 20008`. The higher Android code is deliberate: older internal test builds used greater version codes than 1, and Android never allows an in-place versionCode downgrade. For each later public version, increase both the displayed version and Android versionCode monotonically.

Only a successful build with validated assets and SHA-256 sums is eligible for the **v0.0.8** GitHub prerelease. APK and AAB are development builds, not Google Play production-signed bundles. **An online upgrade of the app is not required for gameplay.**

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

## Procedural landscapes (v0.0.8)

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

## Splash-first visual parity work (v0.0.8)

The Android launch layout is rebuilt around an original scalable layered
landscape illustration (mountain peaks, rivers, forest silhouettes and a
hillside castle), the NOVATERRA crystal emblem, gold wordmark, tagline,
and an emerald extraction/progress indicator. The same native Luanti
`progressBar` and `textView` IDs are kept, and the landscape fills screens
with `centerCrop` rather than stretched pixels. The artwork is a first
implemented art direction, **not yet pixel-for-pixel identical** to the
reference image. Gameplay and main-menu screens will be compared separately.

## Selected world details (v0.0.8)

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

## Standalone NOVATERRA start menu (v0.0.8)

The default entry view is now an independent premium start screen over the
original panoramic menu background. Its **NASTAVI**, **NOVA IGRA**,
**MOJI SVJETOVI**, **POSTAVKE** and **IZLAZ** actions are wired to Luanti's
actual singleplayer world startup, native creation dialog, world list,
native settings dialog and application close callback. Continue validates the
last selected *existing NOVATERRA* world before launching; a missing or
deleted world routes to the worlds list instead of crashing or loading a
different game's save. The Worlds screen has a working **NATRAG** button to
return to the start screen. The original confirm-before-delete and mapgen
settings remain native. All state stays on-device.

Reference images remain acceptance targets. The existing panoramic menu
art is **not** a live voxel-rendered 3D scene and there are no certified
phone/tablet screenshot comparisons yet.

## NOVATERRA menu art and player-facing polish (v0.0.8)

Android packages contain an original deterministic panoramic mountain,
river, pine forest and village illustration rendered at **1440 × 810** by
`assets/branding/generate_menu_landscape.py` (Python standard library only).
Luanti loads it via the game's real `menu/background.png` theme interface.
The main screen uses a semitransparent premium palette over the panorama and
keeps the native working play, create, world settings and confirmed deletion
handlers. Player-facing engine debug warning and placeholder technical text
are hidden, without changing Android's debug build/signing status.

**Not yet 1:1:** This is real packaged illustrative menu artwork, not a live
three-dimensional voxel preview or a screenshot of game runtime. Device tests
and screenshot comparisons remain open in `docs/qa/ANDROID_VISUAL_QA.md`.

## In-game menu UX polish (v0.0.8)

NOVATERRA no longer sends a technical chat command instruction on every
join or opens a blocking menu on the first in-world frame. New players receive
one locally craftable NOVATERRA manual to open the real interactive menu when
desired, and existing players keep their old manual. The classic layout uses
consistent Croatian labels instead of stock English or engine notices.
The action callbacks and offline survival state remain unchanged.

No visual 1:1 claim or physical device QA is implied by passing Lua tests.

## Touch UI

The current build includes a branded splash, Android launcher icon, touch-optimized menus, pixel-heart and food HUD, crafting inventory, map and a quest journal. Primary touch-menu actions have automated Lua tests. UI visuals remain a **work in progress** compared with the supplied reference screenshots; do not represent concept artwork as actual gameplay screenshots.

## Production requirements

Physical-device launch, cold/restart, offline airplane-mode testing, landscape safe areas, gameplay stability, performance, privacy and screen-by-screen visual comparison remain necessary. Android production release signing keys and Google Play validation are not yet configured. A debug AAB must not be presented as production-signed.
