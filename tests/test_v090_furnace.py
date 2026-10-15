from pathlib import Path
import unittest
ROOT = Path(__file__).resolve().parents[1]
class FurnaceContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.src=(ROOT/'games/novaterra/mods/nv_world/furnace.lua').read_text()
    def test_registered_node_and_recipe(self):
        self.assertIn("core.register_node('nv_world:furnace'",self.src)
        self.assertIn("core.register_craft({type='cooking'",self.src)
    def test_inventory_protection(self):
        self.assertIn('core.is_protected',self.src)
        self.assertIn("listname=='dst'",self.src)
        self.assertIn('can_dig=function',self.src)
    def test_timer_and_progress(self):
        self.assertIn('on_timer=function',self.src)
        self.assertIn("meta:set_int('progress', progress)",self.src)
        self.assertIn("meta:set_int('fuel_remaining', remaining)",self.src)
if __name__=='__main__': unittest.main()
