#!/usr/bin/env python3
"""Prepare an independently installable Android build of the native Luanti client."""
from __future__ import annotations

import argparse
import pathlib
import shutil

from offline_mainmenu import patch_offline_mainmenu

APP_ID = "com.brendigo.novaterra"
# Public game release numbering begins at 0.0.4. Android's versionCode is
# separate from the visible version and must NOT decrease relative to earlier
# internal 1.2.0-dev builds, or upgrades could strand on-device saves.
VERSION_NAME = "0.0.4"
VERSION_CODE = 20004
PNG_COUNT = 21


def replace_once(text: str, old: str, new: str, where: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected one occurrence of {old!r} in {where}, found {count}")
    return text.replace(old, new, 1)


def prepare(engine: pathlib.Path, project: pathlib.Path) -> None:
    engine = engine.resolve()
    project = project.resolve()
    source = project / "games/novaterra"
    if not (source / "game.conf").is_file():
        raise SystemExit("NOVATERRA game configuration is missing")
    textures = list(source.rglob("*.png"))
    if len(textures) != PNG_COUNT:
        raise SystemExit(f"Expected {PNG_COUNT} original PNG textures, found {len(textures)}")
    destination = engine / "games" / "novaterra"
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(source, destination)

    patch_offline_mainmenu(engine)

    gradle_path = engine / "android/app/build.gradle"
    gradle = gradle_path.read_text(encoding="utf-8")
    gradle = replace_once(
        gradle, "applicationId 'net.minetest.minetest'",
        f"applicationId '{APP_ID}'", "android/app/build.gradle"
    )
    gradle = replace_once(
        gradle, 'versionName "${versionMajor}.${versionMinor}.${versionPatch}"',
        f'versionName "{VERSION_NAME}"', "android/app/build.gradle"
    )
    gradle = replace_once(
        gradle,
        "versionCode versionMajor * 1000000 + versionMinor * 10000 + versionPatch * 100 + versionBuild",
        f"versionCode {VERSION_CODE}", "android/app/build.gradle"
    )
    gradle = replace_once(
        gradle,
        "include 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'",
        "include 'arm64-v8a'", "android/app/build.gradle"
    )
    # Upstream zipAssets packs a generated assets.zip; include the game in it.
    marker = 'file("${assetsFolder}/.nomedia").text = ""'
    game_assets_copy = """
        copy {
            from "${projRoot}/games/novaterra" into "${assetsFolder}/games/novaterra"
        }
        copy {
            from "${projRoot}/android/novaterra-mobile.conf"
            into "${assetsFolder}"
            rename { "minetest.conf" }
        }
"""
    gradle = replace_once(
        gradle, marker, game_assets_copy + "\n\t\t" + marker,
        "android/app/build.gradle"
    )
    # Android-specific default settings are bundled with the game's asset archive.
    # They preserve the upstream native engine and its touch implementation.
    # Users can override these in their own settings after first launch.
    mobile_settings = "\n".join(['# NOVATERRA mobile defaults','touchscreen_threshold = 10','touch_sensitivity = 0.22','hud_scaling = 0.9','gui_scaling = 0.95','enable_shaders = true','fps_max = 60','viewing_range = 100', 'menu_last_game = novaterra', 'enable_server = false', 'server_announce = false', 'serverlist_url = ', 'contentdb_enable_updates_indicator = false']) + "\n"
    mobile_settings_path = engine / "android" / "novaterra-mobile.conf"
    mobile_settings_path.write_text(mobile_settings, encoding="utf-8")
    gradle_path.write_text(gradle, encoding="utf-8")

    # Install the branded Android shell as real resources. Keep the engine's
    # MainActivity and progress callbacks intact so asset extraction remains safe.
    res_folder = engine / "android/app/src/main/res"
    branding_folder = project / "res"
    resources = {
        "drawable/novaterra_mark.xml": "drawable/novaterra_mark.xml",
        "drawable/novaterra_splash_background.xml": "drawable/novaterra_splash_background.xml",
        "drawable/novaterra_landscape.xml": "drawable/novaterra_landscape.xml",
        "drawable-land/novaterra_landscape.xml": "drawable-land/novaterra_landscape.xml",
        "layout/novaterra_splash.xml": "layout/activity_main.xml",
    }
    for source_name, target_name in resources.items():
        source_path = branding_folder / source_name
        if not source_path.is_file():
            raise SystemExit(f"Missing NOVATERRA Android branding resource: {source_path}")
        destination_path = res_folder / target_name
        destination_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source_path, destination_path)

    # Keep the operating-system launch window dark before MainActivity draws.
    # The default upstream drawable can flash during cold starts.
    styles_path = engine / "android/app/src/main/res/values/styles.xml"
    styles = styles_path.read_text(encoding="utf-8")
    styles = replace_once(
        styles, '<item name="android:windowBackground">@drawable/bg</item>',
        '<item name="android:windowBackground">#091820</item>', "styles.xml"
    )
    styles_path.write_text(styles, encoding="utf-8")

    manifest_path = engine / "android/app/src/main/AndroidManifest.xml"
    manifest = manifest_path.read_text(encoding="utf-8")
    for extension in (".fileprovider", ".documents"):
        manifest = replace_once(
            manifest, f"net.minetest.minetest{extension}",
            f"{APP_ID}{extension}", "AndroidManifest.xml"
        )
    manifest = replace_once(
        manifest, 'android:icon="@mipmap/ic_launcher"',
        'android:icon="@drawable/novaterra_mark"', "AndroidManifest.xml"
    )
    manifest_path.write_text(manifest, encoding="utf-8")

    activity = engine / "android/app/src/main/java/net/minetest/minetest/GameActivity.java"
    java = activity.read_text(encoding="utf-8")
    java = replace_once(
        java, '"net.minetest.minetest.fileprovider"',
        f'"{APP_ID}.fileprovider"', "GameActivity.java"
    )
    java = replace_once(
        java, "setSmallIcon(R.mipmap.ic_launcher)",
        "setSmallIcon(R.drawable.novaterra_mark)", "GameActivity.java"
    )
    activity.write_text(java, encoding="utf-8")

    strings_path = engine / "android/app/src/main/res/values/strings.xml"
    strings = strings_path.read_text(encoding="utf-8")
    strings = replace_once(
        strings, '<string name="label">Luanti</string>',
        '<string name="label">NOVATERRA</string>', "strings.xml"
    )
    strings = strings.replace("Loading Luanti", "Loading NOVATERRA")
    strings = strings.replace("Luanti is running", "NOVATERRA is running")
    strings = strings.replace("Notifications from Luanti", "NOVATERRA updates")
    strings = strings.replace("Loading&#8230;", "Preparing NOVATERRA&#8230;")
    strings_path.write_text(strings, encoding="utf-8")
    print(f"Prepared {APP_ID} ({VERSION_NAME}; code {VERSION_CODE}) with {len(textures)} original textures")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--luanti", type=pathlib.Path, required=True)
    parser.add_argument("--project", type=pathlib.Path, default=pathlib.Path("."))
    args = parser.parse_args()
    prepare(args.luanti, args.project)


if __name__ == "__main__":
    main()
