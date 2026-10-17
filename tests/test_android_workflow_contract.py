"""Regression: APK assets.zip includes engine textures as well as game textures."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/android-game.yml"


class AndroidPackagingAudit(unittest.TestCase):
    def test_count_only_novaterra_textures(self):
        content = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn(
            "grep -Ec '^games/novaterra/mods/[^/]+/textures/[^/]+[.]png$'",
            content,
        )
        self.assertNotIn("grep -c 'textures/.*[.]png'", content)

    def test_first_release_version_matches_build(self):
        game = WORKFLOW.read_text(encoding="utf-8")
        release = (ROOT / ".github/workflows/android-release.yml").read_text(encoding="utf-8")
        self.assertIn("EXPECTED_VERSION_CODE=20009", game)
        self.assertIn("versionName='0.0.9'", game)
        self.assertIn("TAG=v0.0.9", release)
        self.assertIn("test \"$SOURCE_SHA\" = \"$HEAD_SHA\"", release)
        for content in (game, release):
            self.assertIn("NOVATERRA-Android-arm64-v0.0.9-debug.apk", content)
            self.assertIn("NOVATERRA-Android-v0.0.9-debug.aab", content)
        self.assertIn("SHA256SUMS.txt", release)

    def test_verify_actual_game_content(self):
        content = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("games/novaterra/mods/nv_rpg/init.lua", content)
        self.assertIn("games/novaterra/mods/nv_core/textures/nv_stone.png", content)
        self.assertIn("IMAGE_COUNT", content)
        self.assertEqual(content.count("IMAGE_COUNT=$("), 1)
        self.assertEqual(content.count("      - uses: actions/upload-artifact@v4"), 1)
        self.assertIn("sha256sum ./*.apk ./*.aab > SHA256SUMS.txt", content)


if __name__ == "__main__":
    unittest.main()
