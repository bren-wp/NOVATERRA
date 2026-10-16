# NOVATERRA

![NOVATERRA – Build, Explore, Survive, Thrive](assets/branding/novaterra-banner.svg)

**BUILD · EXPLORE · SURVIVE · THRIVE**

An original **offline, Android-only voxel survival game**. Explore procedural worlds, gather resources, craft tools, survive the night and progress through quests. No account or external game server is required to play singleplayer.

[![Android APK & AAB](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml)
[![Source validation](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml)
[![Game runtime](https://github.com/bren-wp/NOVATERRA/actions/workflows/luanti-smoke.yml/badge.svg)](https://github.com/bren-wp/NOVATERRA/actions/workflows/luanti-smoke.yml)

## One Android game, no external game servers

- **Android arm64** – native C++/OpenGL ES runtime with integrated Luanti singleplayer engine and Lua game modules.
- **Offline worlds** – generated, played and saved locally on the device.
- **Singleplayer only** – public server browser, external ContentDB and in-engine update checks removed from the Android menu.
- **Touch-first** – real touch movement, building/mining controls, scalable HUD, inventory and menus.
- **Local progression** – persistent health, hunger, items, world map and waypoint, five quests, levels and XP.
- **Survival world** – biomes, caves, trees, stone, coal/iron, furnace, cooking, wildlife and hostile creatures.

The engine internally operates a local singleplayer game service; that **does not require an external server**. Certain native engine components may use local loopback sockets. Internet access should not be required to play, but independence from all outbound traffic still needs a device-level network audit.

## Development builds

- [Android APK/AAB CI builds](https://github.com/bren-wp/NOVATERRA/actions/workflows/android-game.yml)
- [Android-only development releases](https://github.com/bren-wp/NOVATERRA/releases)
- [Automated code and game tests](https://github.com/bren-wp/NOVATERRA/actions/workflows/source-validation.yml)

Releases are created **only after** the compiled Android APK and AAB pass checksum and archive integrity checks. The current development AAB is **debug-signed**, not a Google Play production release. A Play-compatible AAB requires proper release signing, physical-device testing and Play checks.

## Gameplay and menus

Explore the generated world, mine blocks, craft tools and a furnace, cook food, avoid hostile creatures and complete RPG objectives. The NOVATERRA in-game menu, inventory, quests and map are available by touch. Touch controls are provided by the integrated native engine. The game and all original textures are included in the application.

## Visual reference fidelity

The owner's supplied reference images define the target for the launch screen, game menu, world selection, HUD, inventory, map, interactions and creature presentation. The implemented menus and HUD are functional development steps, **not proof of exact 1:1 visual parity**. Real screenshots from installed builds and screen-by-screen comparison are required. See [UI parity](docs/UI-PARITY.md).

## Project structure

| Directory | Purpose |
|---|---|
| [android/](android/) | Native Android build integration, splash screen, icon and offline engine customization |
| [games/novaterra/](games/novaterra/) | Game content, world generation, inventory, survival, AI and quests |
| [tests/](tests/) | Gameplay tests, Android preparation and UI integration checks |
| [.github/workflows/](.github/workflows/) | Android builds, verified Android prereleases and source/runtime checks |

NOVATERRA targets **Android only**. Windows and iOS applications are not maintained or distributed from this repository.

## Licensing

The project source license is in [LICENSE](LICENSE). The bundled upstream Luanti runtime retains its own copyright notices and licenses. Review third-party licenses and perform a security and privacy audit before any production distribution.
