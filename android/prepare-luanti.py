#!/usr/bin/env python3
"""Prepare an independently installable Android build of the native Luanti client."""
from __future__ import annotations

import argparse
import pathlib
import shutil

APP_ID = "com.brendigo.novaterra"
VERSION_NAME = "1.2.0-dev"
VERSION_CODE = 12001
PNG_COUNT = 17


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
"""
    gradle = replace_once(
        gradle, marker, game_assets_copy + "\n\t\t" + marker,
        "android/app/build.gradle"
    )
    gradle_path.write_text(gradle, encoding="utf-8")

    manifest_path = engine / "android/app/src/main/AndroidManifest.xml"
    manifest = manifest_path.read_text(encoding="utf-8")
    for extension in (".fileprovider", ".documents"):
        manifest = replace_once(
            manifest, f"net.minetest.minetest{extension}",
            f"{APP_ID}{extension}", "AndroidManifest.xml"
        )
    manifest_path.write_text(manifest, encoding="utf-8")

    activity = engine / "android/app/src/main/java/net/minetest/minetest/GameActivity.java"
    java = activity.read_text(encoding="utf-8")
    java = replace_once(
        java, '"net.minetest.minetest.fileprovider"',
        f'"{APP_ID}.fileprovider"', "GameActivity.java"
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
