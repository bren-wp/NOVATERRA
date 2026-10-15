from pathlib import Path
import unittest
ROOT = Path(__file__).resolve().parents[1] / 'games/novaterra/mods'
class RegressionTests(unittest.TestCase):
    def test_glass_requires_smelting(self):
        code = (ROOT/'nv_core/init.lua').read_text()
        self.assertIn("type='cooking', output='nv_core:glass'", code)
        self.assertNotIn("output='nv_core:glass',recipe", code)
    def test_no_free_torches(self):
        code = (ROOT/'nv_core/init.lua').read_text()
        self.assertNotIn("output='nv_core:torch 4'", code)
        self.assertIn("output='nv_core:torch 4'", (ROOT/'nv_world/init.lua').read_text())
    def test_craftpreview_engine_managed(self):
        code = (ROOT/'nv_core/init.lua').read_text()
        self.assertNotIn("set_size('craftpreview'", code)
    def test_vegetation_engine_decorations(self):
        code = (ROOT/'nv_world/init.lua').read_text()
        self.assertIn("core.register_node('nv_world:tall_grass'", code)
        self.assertIn("decoration='nv_world:tall_grass'", code)
    def test_ui_dependency(self):
        conf = (ROOT/'nv_ui/mod.conf').read_text()
        self.assertIn('nv_survival', conf)
if __name__ == '__main__': unittest.main()
