"""RPG progression checks: source contracts and UI hooks.

The Luanti server smoke workflow also verifies that the modules load.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1] / "games" / "novaterra" / "mods"

class RPGContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rpg=(ROOT / "nv_rpg" / "init.lua").read_text(encoding="utf-8")
        cls.mobs=(ROOT / "nv_mobs" / "init.lua").read_text(encoding="utf-8")
        cls.ui=(ROOT / "nv_ui" / "init.lua").read_text(encoding="utf-8")
        cls.inventory=(ROOT / "nv_core" / "init.lua").read_text(encoding="utf-8")

    def test_quests_and_completion_guards(self):
        for name in ("wood", "stone", "ore", "craft", "hunter"):
            self.assertIn(name + " = {", self.rpg)
        self.assertIn("previous >= def.goal", self.rpg)
        self.assertIn("meta:set_int(key(id), current)", self.rpg)
        self.assertIn('meta:set_int("nv_rpg_xp"', self.rpg)

    def test_event_hooks(self):
        self.assertIn("register_on_dignode", self.rpg)
        self.assertIn("register_on_craft", self.rpg)
        self.assertIn("record_defeat", self.rpg)
        self.assertIn("novaterra_rpg.record_defeat(puncher, self.kind)", self.mobs)

    def test_mobile_friendly_entry_points(self):
        self.assertIn("ZADACI I POSTIGNUCA", self.ui)
        self.assertIn("novaterra_rpg.show(player)", self.ui)
        self.assertIn("nv_quests;QUEST JOURNAL", self.inventory)

    def test_module_depends(self):
        dependencies=(ROOT / "nv_rpg" / "mod.conf").read_text(encoding="utf-8")
        self.assertIn("nv_mobs", dependencies)

if __name__ == "__main__":
    unittest.main()
