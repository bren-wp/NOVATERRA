from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class FurnaceResilience(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code=(ROOT/'games/novaterra/mods/nv_world/furnace.lua').read_text()
    def test_restart_resume(self):
        self.assertIn('core.register_lbm({',self.code)
        self.assertIn('run_at_every_load=true',self.code)
    def test_output_protection(self):
        self.assertIn("listname=='dst'",self.code)
        self.assertIn("inv:room_for_item('dst', result)",self.code)
    def test_inventory_callback(self):
        self.assertIn('on_metadata_inventory_move=function',self.code)
    def test_progress_text(self):
        self.assertIn("meta:set_string('infotext'",self.code)
if __name__=='__main__': unittest.main()
