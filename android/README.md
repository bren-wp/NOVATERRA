# NOVATERRA for Android

Android-specific packaging, signing and touch UI work belongs in this directory. The shared Luanti game is in `../games/novaterra`.

**Status:** no Android Gradle project, APK or AAB is currently built or verified. This directory establishes the platform boundary only.

Production requirements:
- Integrate a compatible Luanti Android engine and respect its licenses.
- Bundle the complete NOVATERRA game, textures and mod dependencies.
- Adapt formspec layouts, hotbar and controls to phones/tablets.
- Build signed release AAB/APK with unique versionCode.
- Smoke-test launch, world creation, inventory, furnace, HUD and persistence on actual Android devices.
