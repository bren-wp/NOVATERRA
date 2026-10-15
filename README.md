# NOVATERRA

![NOVATERRA — Build, Explore, Survive, Thrive](assets/branding/novaterra-banner.svg)

**Build worlds. Explore the unknown. Survive your own adventure.**

A voxel survival and crafting game in development for **Windows** and **Android**. Discover procedural biomes, mine resources, craft tools and shape your world.

[![Source validation](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml)
[![Real-engine smoke test](https://github.com/bren-wp/NOVATERRA/actions/workflows/luanti-smoke.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/luanti-smoke.yml)
[![Windows build](https://github.com/bren-wp/NOVATERRA/actions/workflows/windows-game.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/windows-game.yml)
[![Android build](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml)
![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Android-192C3B)
![Status](https://img.shields.io/badge/status-development-D69E35)

> **Development preview:** Complete original v1.1.0 gameplay source and all 17 textures are in GitHub. A native Windows x64 portable package has passed GitHub Actions packaging and Luanti engine checks; a real Linux Luanti server has loaded the game and listened for connections. An Android arm64 development APK and AAB have passed build and checksum verification; final in-hand device tests and visual parity checks remain outstanding. The supplied design images are targets, **not** screenshots of running builds.

## Discover NOVATERRA

🌍 **Explore** — procedural biomes and terrain  
⛏️ **Mine** — collect stone, coal and iron  
🛠️ **Craft** — tools, torches, a working furnace and building blocks  
❤️ **Survive** — persistent health, hunger, cooking and food  
🏡 **Build** — create your own shelters and worlds  
🦌 **Encounter** — roaming wildlife, cave enemies, combat and loot  
🏆 **Progress** — five quests, XP, levels and an in-game quest journal  
🎮 **Play your way** — planned Windows keyboard/mouse and Android touch controls

## Visual direction

The visual references supplied by the project owner define the target for the splash screen, main menu, HUD, inventory and settings. They are not included as verified in-game screenshots. The implementation and comparison checklist is in [UI parity](docs/UI-PARITY.md).

## Platforms

| | Windows | Android |
|---|---|---|
| Platform folder | [windows/](windows/) | [android/](android/) |
| Interface goal | Desktop controls | Touch controls |
| Packaging goal | EXE / installer | APK / AAB |
| Packaging status | ✅ Portable ZIP and unsigned Setup EXE builds verified in CI | ✅ arm64 development APK and AAB build verified in CI |
| Real gameplay/device visual test | ⏳ Not yet | ⏳ Not yet |

Both platforms must use an actual compiled platform engine, not a webview pretending to be a native application. Shared Lua game content lives in `games/novaterra/`.

## Development

**Windows development builds:** [Portable ZIP and Windows Setup CI output](https://github.com/bren-wp/NOVATERRA/actions/runs/38823694526) (GitHub sign-in may be required). The packages contain the Windows launcher, the pinned Luanti engine and NOVATERRA game data. The Setup EXE is currently unsigned, and a passing CI build is **not** an in-hand gameplay certification.

**Headless runtime:** [NOVATERRA loaded into a real Luanti server](https://github.com/bren-wp/NOVATERRA/actions/runs/38822429862) and listened on UDP game port 30491 for the duration of a 22-second smoke test.

**Android:** [Successful APK/AAB CI build](https://github.com/bren-wp/NOVATERRA/actions/runs/38821920870) — debug APK and test AAB contain the native-engine game. Newer builds may be underway; these are development-signed, **not** Google Play production releases.

For development, the [PowerShell launcher](windows/Launch-NOVATERRA.ps1) additionally supports an installed external Luanti executable.

Check [GitHub Actions](https://github.com/bren-wp/NOVATERRA/actions) for current test results and [issue #1](https://github.com/bren-wp/NOVATERRA/issues/1) for missing migration/build steps.

## Releases

A development prerelease workflow is configured to publish a **portable Windows ZIP, Windows Setup EXE, Android APK and Android AAB** only after both builds for the same source commit pass integrity checks. Releases are commit-qualified as `v1.2.0-dev.<commit>`. A draft without attachments is **not** a published release. The automated workflow retries recoverable GitHub API failures; always verify the published release contains all four packages. See [GitHub Releases](https://github.com/bren-wp/NOVATERRA/releases).

## In-game controls and progression

Start a NOVATERRA world from the engine's singleplayer screen. Open your inventory to craft and manage the backpack. Use **/novaterra** for the in-game menu, **/nvmap** for coordinates and a saved waypoint, and **/nvquests** for RPG objectives and XP. Food, survival metadata, waypoint coordinates and quest progress are stored per player.

**Design fidelity:** The owner-provided menu, character, HUD and world images remain visual references rather than gameplay screenshots. The current build uses Luanti's main menu and temporary cube creature visuals; 1:1 visuals and polished animations are still outstanding. This README's banner is original branding artwork, not a gameplay capture.

## Licensing

See [LICENSE](LICENSE). Engine and third-party asset licenses must be reviewed before redistributing bundled applications.
