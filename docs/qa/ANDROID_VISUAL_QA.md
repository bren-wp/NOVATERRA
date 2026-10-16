# NOVATERRA — Android UI/UX visual QA, required before calling it 1:1

**Status: not certified.** Reference concept boards are not real runtime captures.
Close [production gate #5](https://github.com/bren-wp/NOVATERRA/issues/5)
only after obtaining images from installed NOVATERRA APKs on an Android
phone AND a tablet and independently checking all interactive behaviors.

## Evidence requirements

For each device record model, Android release, screen pixel dimensions,
display density, display cutout/safe-area information, app versionCode,
GitHub commit, exact installed APK SHA-256 and whether airplane mode is on.
Capture unmodified PNGs via `adb exec-out screencap -p`, never from promotional
artwork, the concept boards or an image mockup. Keep reference and captured
images in separate folders.

Example from a computer with Android platform-tools installed:

```bash
adb devices -l
adb -s DEVICE shell wm size
adb -s DEVICE shell wm density
adb -s DEVICE shell am force-stop com.brendigo.novaterra
adb -s DEVICE shell monkey -p com.brendigo.novaterra 1
adb -s DEVICE exec-out screencap -p > phone-main-menu.png
```

For the actual loading splash, capture during first asset extraction;
do not manufacture loading text for subsequent warm starts.

## Six required screen families

1. **Splash:** Screenshot with background, correct logo scale, real loading
   indicator, no window flash or clipping in landscape on phone and tablet.
2. **Main menu:** Compare original 3D voxel background and positions of every
   real working button against the matching reference. No multiplayer,
   servers or store/account placeholders.
3. **Worlds:** Test native local create/play/configure/delete (including
   confirmation and cancellation). Capture the selected-world details modal;
   verify name, seed, map generator and creative/damage mode against world.mt.
   Never invent creation/last-played dates or preview screenshots.
4. **HUD:** Real in-world screenshot of health/hunger, hotbar, touch joystick,
   interaction buttons and minimap, and inspection of screen safe areas,
   notch, gesture navigation and tablet scale.
5. **Gameplay navigation:** Real inventory, crafting grid, furnace smelting,
   RPG/quests, map, settings and return-to-game screenshots. Test every button,
   recipe and state persistence rather than only formspec text.
6. **Device QA:** Capture both device form factors, restart after process kill,
   run with airplane mode enabled, compare geometry against reference frames.
   Record exact mismatches and rerun after each layout adjustment.

## QA checklist

| Requirement | Static or headless test | Real screenshot/interaction |
| --- | --- | --- |
| Responsive splash and genuine native progress | XML and Android build | **PENDING** |
| Main menu with **3D** preview matching reference | Offline patch tests | **PENDING** |
| Local worlds and safe deletion | Luanti callback + metadata tests | **PENDING** |
| HUD, touch, hotbar, minimap, safe areas | Gameplay code tests | **PENDING** |
| Inventory, crafting, furnace, RPG, map, settings | Lua tests | **PENDING** |
| Android phone + tablet 1:1 screenshot pairs | No substitute | **PENDING** |

CI and debug APK/AAB artifacts with SHA-256 establish **build integrity**,
not design parity, actual FPS, runtime safety, device compatibility or
production signing. Do not mark any checkbox complete without matching real
device evidence. The UI under development is Android-only and offline.
