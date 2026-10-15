from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1] / 'games' / 'novaterra' / 'mods'
class WorldTests(unittest.TestCase):
    def test_world_registration(self):
        code = (ROOT/'nv_world'/'init.lua').read_text()
        self.assertEqual(code.count("biome('"), 5)
        self.assertEqual(code.count('core.register_ore({'), 2)
        for item in ('coal_ore','iron_ore','raw_iron','nv_core:stone'):
            self.assertIn(item, code)
    def test_textures(self):
        for name in ('coal','iron'):
            data=(ROOT/'nv_world'/'textures'/f'nv_{name}_overlay.png').read_bytes()
            self.assertEqual(data[:8], b'\x89PNG\r\n\x1a\n')
    def test_status(self):
        self.assertIn("register_chatcommand('nvstatus'", (ROOT/'nv_ui'/'init.lua').read_text())
if __name__ == '__main__': unittest.main()
