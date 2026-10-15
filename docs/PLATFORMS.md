# Platform architecture

## Windows
A Windows executable should be compiled from the compatible Luanti desktop engine and bundled with NOVATERRA game assets. Desktop-specific packaging scripts and installer files belong in `windows/`. The PowerShell launcher is for development only.

## Android
The Android client must be compiled using the compatible Luanti Android application and native Android packaging toolchain. The app must ship with touch controls, lifecycle handling, permissions, a unique package identifier, release signing and Play-compatible AAB. Platform files belong in `android/`.

## Shared content
Game rules, procedural world generation, crafting, inventory and progression are shared Lua game logic in `games/novaterra/`. Both clients run the same game data.

## Limitations
This is a target architecture, **not** a claim that native Windows and Android binaries already exist.
