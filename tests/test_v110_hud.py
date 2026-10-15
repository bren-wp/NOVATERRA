"""Static HUD integration checks; engine integration remains required."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]/'games'/'novaterra'/'mods'
class HudContracts(unittest.TestCase):
    def test_settings_wired(self):
        ui=(ROOT/'nv_ui'/'init.lua').read_text()
        self.assertIn('coordinates_visible',ui)
        self.assertIn('novaterra_survival.set_coordinates_visible(player',ui)
    def test_server_side_metadata(self):
        survival=(ROOT/'nv_survival'/'init.lua').read_text()
        self.assertIn("set_int('nv_show_coordinates'",survival)
        self.assertIn("get_int('nv_show_coordinates'",survival)
    def test_hud_is_independent(self):
        survival=(ROOT/'nv_survival'/'init.lua').read_text()
        self.assertIn("data.hud_coordinates",survival)
        self.assertIn("data.coordinates_visible",survival)
    def test_hp_uses_player_maximum(self):
        survival=(ROOT/'nv_survival'/'init.lua').read_text()
        self.assertIn('hp_max or 20',survival)
if __name__=='__main__': unittest.main()
