# NOVATERRA

**Build worlds. Explore the unknown. Survive your own adventure.**

A voxel survival and crafting game in development for **Windows** and **Android**. Discover procedural biomes, mine resources, craft tools and shape your world.

[![Source validation](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml)
[![Real-engine smoke test](https://github.com/bren-wp/NOVATERRA/actions/workflows/luanti-smoke.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/luanti-smoke.yml)
[![Windows build](https://github.com/bren-wp/NOVATERRA/actions/workflows/windows-game.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/windows-game.yml)
[![Android build](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml)
![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Android-192C3B)
![Status](https://img.shields.io/badge/status-development-D69E35)

> **Development preview:** Complete original v1.1.0 gameplay source and all 17 textures are in GitHub. A native Windows x64 portable package has passed GitHub Actions packaging and Luanti engine checks; a real Linux Luanti server has loaded the game and listened for connections. Android compilation and on-device validation are ongoing. The supplied design images are targets, **not** screenshots of running builds.

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
| Packaging status | ✅ Portable x64 ZIP generated | 🔄 Native APK/AAB build in progress |
| Real gameplay/device visual test | ⏳ Not yet | ⏳ Not yet |

Both platforms must use an actual compiled platform engine, not a webview pretending to be a native application. Shared Lua game content lives in `games/novaterra/`.

## Development

**Windows portable preview:** [Download the verified build artifact from GitHub Actions](https://github.com/bren-wp/NOVATERRA/actions/runs/38822084852) (GitHub sign-in may be required). The ZIP contains the Windows launcher, the official pinned Luanti engine and the complete NOVATERRA source and textures. Extract the archive before starting `NOVATERRA.exe`. This packaging result is **not** a full user-device gameplay test.

**Headless runtime:** [NOVATERRA loaded into a real Luanti server](https://github.com/bren-wp/NOVATERRA/actions/runs/38822429862) and listened on TCP/UDP game port 30491 for the duration of a 22-second smoke test.

**Android:** [Build status and debug packages](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml) — debug artifacts will be downloadable only after a successful build, and are not Play Store-signed releases.

For development, the [PowerShell launcher](windows/Launch-NOVATERRA.ps1) additionally supports an installed external Luanti executable.

Check [GitHub Actions](https://github.com/bren-wp/NOVATERRA/actions) for current test results and [issue #1](https://github.com/bren-wp/NOVATERRA/issues/1) for missing migration/build steps.

## Releases

A v1.2.0-dev prerelease workflow is configured to publish **both** real Windows and Android artifacts only after both build pipelines pass their integrity checks. Until those checks succeed, do not treat any missing GitHub release as published. See [GitHub Releases](https://github.com/bren-wp/NOVATERRA/releases).

## Licensing

See [LICENSE](LICENSE). Engine and third-party asset licenses must be reviewed before redistributing bundled applications.
