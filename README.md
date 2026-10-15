# NOVATERRA

**Build worlds. Explore the unknown. Survive your own adventure.**

A voxel survival and crafting game in development for **Windows** and **Android**. Discover procedural biomes, mine resources, craft tools and shape your world.

[![Source validation](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml)
![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Android-192C3B)
![Status](https://img.shields.io/badge/status-development-D69E35)

> **Early development:** This repository currently contains an incomplete Luanti-based prototype. No tested Windows executable, Android APK or AAB has been released. Screenshots from the design brief are targets, not screenshots of running builds.

## Discover NOVATERRA

🌍 **Explore** — procedural biomes and terrain  
⛏️ **Mine** — collect stone, coal and iron  
🛠️ **Craft** — tools, torches and building blocks  
❤️ **Survive** — health and hunger systems (in development)  
🏡 **Build** — create your own shelters and worlds  
🎮 **Play your way** — planned Windows keyboard/mouse and Android touch controls

## Visual direction

The visual references supplied by the project owner define the target for the splash screen, main menu, HUD, inventory and settings. They are not included as verified in-game screenshots. The implementation and comparison checklist is in [UI parity](docs/UI-PARITY.md).

## Platforms

| | Windows | Android |
|---|---|---|
| Platform folder | [windows/](windows/) | [android/](android/) |
| Interface goal | Desktop controls | Touch controls |
| Packaging goal | EXE / installer | APK / AAB |
| Verified runnable build | ❌ Not yet | ❌ Not yet |

Both platforms must use an actual compiled platform engine, not a webview pretending to be a native application. Shared Lua game content lives in `games/novaterra/`.

## Development

Windows developers can inspect [the launcher](windows/Launch-NOVATERRA.ps1). It requires an installed Luanti engine and a complete game directory; the source migration is not finished.

Check [GitHub Actions](https://github.com/bren-wp/NOVATERRA/actions) for current test results and [issue #1](https://github.com/bren-wp/NOVATERRA/issues/1) for missing migration/build steps.

## Releases

A release is published only after its artifacts exist and have been checked. Until then, commits and CI runs are development checkpoints, not production releases.

## Licensing

See [LICENSE](LICENSE). Engine and third-party asset licenses must be reviewed before redistributing bundled applications.
