"""Validate NOVATERRA source tree and imported original textures."""
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "games" / "novaterra"
MODS = GAME / "mods"


class RepositoryIntegrity(unittest.TestCase):
    def test_game_config(self):
        data = (GAME / "game.conf").read_text(encoding="utf-8")
        self.assertIn("name =", data)

    def test_modules_complete(self):
        for mod in ("nv_core", "nv_survival", "nv_ui", "nv_world"):
            with self.subTest(mod=mod):
                self.assertTrue((MODS / mod / "mod.conf").is_file())
                self.assertTrue((MODS / mod / "init.lua").is_file())
                self.assertGreater((MODS / mod / "init.lua").stat().st_size, 100)

    def test_furnace_exists(self):
        source = (MODS / "nv_world" / "furnace.lua").read_text(encoding="utf-8")
        self.assertIn("core.register_node", source)
        self.assertIn("nv_world:furnace", source)
        self.assertIn("on_timer", source)
        self.assertIn("can_dig", source)

    def test_survival_has_persistence(self):
        source = (MODS / "nv_survival" / "init.lua").read_text(encoding="utf-8")
        self.assertIn("register_on_leaveplayer", source)
        self.assertIn("set_coordinates_visible", source)
        self.assertIn("nv_hunger", source)

    def test_textures_valid_png(self):
        for mod in ("nv_core", "nv_world", "nv_survival"):
            texture_dir = MODS / mod / "textures"
            self.assertTrue(texture_dir.is_dir())
            for file in sorted(texture_dir.glob("*.png")):
                with self.subTest(texture=f"{mod}/{file.name}"):
                    data = file.read_bytes()
                    self.assertGreaterEqual(len(data), 33)
                    self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
                    width, height = struct.unpack(">II", data[16:24])
                    self.assertGreater(width, 0)
                    self.assertGreater(height, 0)
        self.assertEqual(len(list(MODS.rglob("*.png"))), 21)


if __name__ == "__main__":
    unittest.main()
