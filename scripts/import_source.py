#!/usr/bin/env python3
"""Safely import the versioned NOVATERRA game package from a verified tar.xz archive."""
from __future__ import annotations

import argparse
import base64
import hashlib
import io
import lzma
import pathlib
import tarfile


EXPECTED_SHA256 = "ce9aad36a42a5491865dd1a8a9e9bd7090d52e2814fb7696d2fd6c58eee5eaaa"
ARCHIVE = "imports/novaterra-v1.1.0-source.tar.xz.b64"


def import_archive(root: pathlib.Path, payload_file: pathlib.Path, expected_sha256: str) -> int:
    text = payload_file.read_text(encoding="ascii")
    try:
        compressed = base64.b64decode("".join(text.split()), validate=True)
    except ValueError as exc:
        raise SystemExit(f"Invalid encoded source: {exc}") from exc
    digest = hashlib.sha256(compressed).hexdigest()
    if digest != expected_sha256:
        raise SystemExit(
            f"Archive checksum mismatch: expected {expected_sha256}, got {digest}"
        )
    if len(compressed) > 2_000_000:
        raise SystemExit("Source archive exceeds safety limit")
    try:
        tar_bytes = lzma.decompress(compressed, memlimit=128 * 1024 * 1024)
    except lzma.LZMAError as exc:
        raise SystemExit(f"Invalid compressed archive: {exc}") from exc

    if len(tar_bytes) > 15_000_000:
        raise SystemExit("Decompressed archive exceeds safety limit")

    root = root.resolve()
    imported = []
    with tarfile.open(fileobj=io.BytesIO(tar_bytes), mode="r:") as source:
        entries = source.getmembers()
        for member in entries:
            name = member.name
            allowed = name.startswith("games/novaterra/") or name.startswith("tests/")
            segments = pathlib.PurePosixPath(name).parts
            if not (
                allowed and member.isfile()
                and ".." not in segments
                and not pathlib.PurePosixPath(name).is_absolute()
                and member.size <= 1_000_000
            ):
                raise SystemExit(f"Unsupported archive entry: {name}")
            target = (root / name).resolve()
            if not target.is_relative_to(root):
                raise SystemExit(f"Unsafe path: {name}")
            imported.append((member, target))

        # Validate every entry before writing any files.
        for member, target in imported:
            content_file = source.extractfile(member)
            if content_file is None:
                raise SystemExit(f"Cannot extract {member.name}")
            data = content_file.read()
            if len(data) != member.size:
                raise SystemExit(f"Incorrect extracted length for {member.name}")
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)

    textures = sum(path.suffix == ".png" for _, path in imported)
    lua = sum(path.suffix == ".lua" for _, path in imported)
    tests = sum(path.name.startswith("test_") for _, path in imported)
    if (textures, lua, tests) != (17, 5, 8):
        raise SystemExit(f"Unexpected file manifest: {textures} PNG, {lua} Lua, {tests} tests")
    print(f"Imported {len(imported)} files: {textures} original PNG textures, {lua} Lua scripts, {tests} tests")
    return len(imported)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path, default=pathlib.Path("."))
    parser.add_argument("--archive", type=pathlib.Path, default=pathlib.Path(ARCHIVE))
    parser.add_argument("--sha256", default=EXPECTED_SHA256)
    args = parser.parse_args()
    import_archive(args.root, args.archive, args.sha256)


if __name__ == "__main__":
    main()
