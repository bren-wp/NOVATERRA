"""Original menu background packaging and rendering contract (not a screenshot test)."""
from pathlib import Path
import hashlib
import struct
import tempfile
import unittest

from assets.branding.generate_menu_landscape import WIDTH, HEIGHT, render_menu_background


class MenuArtwork(unittest.TestCase):
    def test_deterministic_true_color_landscape(self):
        with tempfile.TemporaryDirectory() as root:
            first = render_menu_background(Path(root) / "one/background.png")
            second = render_menu_background(Path(root) / "two/background.png")
            source = first.read_bytes()
            self.assertEqual(source[:8], b"\x89PNG\r\n\x1a\n")
            self.assertEqual(struct.unpack(">II", source[16:24]), (1440, 810))
            self.assertEqual((WIDTH, HEIGHT), (1440, 810))
            self.assertGreater(len(source), 15000)
            self.assertEqual(hashlib.sha256(source).digest(),
                             hashlib.sha256(second.read_bytes()).digest())
            self.assertEqual(source[25], 2, "PNG must be true-color RGB")

    def test_art_script_is_self_contained(self):
        source = (Path(__file__).resolve().parents[1] /
                  "assets/branding/generate_menu_landscape.py").read_text()
        self.assertNotIn("requests.", source)
        self.assertNotIn("http://", source)
        self.assertNotIn("https://", source)
        self.assertIn("random.Random(12643)", source)


if __name__ == "__main__":
    unittest.main()
