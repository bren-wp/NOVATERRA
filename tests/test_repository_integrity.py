"""NOVATERRA repository integration checks.

Run with: python -m unittest discover -s tests -p 'test*.py'
"""
from pathlib import Path
import struct
import re
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
        self.assertRegex(source, r"register_node\\(\\s*['\\\"]nv_world:furnace['\\\"]")
        self.assertIn("on_timer", source)
        self.assertIn("can_dig", source)

    def test_survival_has_persistence(self):
        source = (MODS / "nv_survival" / "init.lua").read_text(encoding="utf-8")
        self.assertIn("register_on_leaveplayer", source)
        self.assertIn("set_coordinates_visible", source)
        self.assertIn("nv_hunger", source)

    def test_windows_launcher(self):
        launcher = (ROOT / "windows" / "Launch-NOVATERRA.ps1").read_text(encoding="utf-8")
        self.assertIn("game.conf", launcher)
        self.assertIn("LuantiExe", launcher)

    def test_textures_valid_png(self):
        textures = {
            "nv_core": ("nv_stone.png", "nv_cobble.png", "nv_grass_top.png",
                        "nv_dirt.png", "nv_tree_side.png", "nv_wood.png"),
            "nv_world": ("nv_coal_overlay.png", "nv_iron_overlay.png"),
        }
        for mod, names in textures.items():
            for name in names:
                with self.subTest(texture=f"{mod}/{name}"):
                    file = MODS / mod / "textures" / name
                    data = file.read_bytes()
                    self.assertGreaterEqual(len(data), 33)
                    self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
                    width, height = struct.unpack(">II", data[16:24])
                    self.assertGreater(width, 0)
                    self.assertGreater(height, 0)


if __name__ == "__main__":
    unittest.main()
