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

    def test_verify_actual_game_content(self):
        content = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("games/novaterra/mods/nv_rpg/init.lua", content)
        self.assertIn("games/novaterra/mods/nv_core/textures/nv_stone.png", content)
        self.assertIn("IMAGE_COUNT", content)
        self.assertIn("sha256sum ./*.apk ./*.aab > SHA256SUMS.txt", content)


if __name__ == "__main__":
    unittest.main()
