from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1] / "games" / "novaterra" / "mods"

class CreatureContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mobs = (ROOT / "nv_mobs" / "init.lua").read_text()
        cls.config = (ROOT / "nv_mobs" / "mod.conf").read_text()
        cls.survival = (ROOT / "nv_survival" / "init.lua").read_text()

    def test_creature_behaviors(self):
        for creature in ("grazer", "crawler", "nightshade"):
            self.assertIn(creature + " = {", self.mobs)
        for method in ("register_entity", "on_punch", "on_step", "player:punch", "drop_loot"):
            self.assertIn(method, self.mobs)

    def test_spawn_limits(self):
        self.assertIn("MAX_ACTIVE_NEAR_PLAYER", self.mobs)
        self.assertIn("get_objects_inside_radius", self.mobs)
        self.assertIn("nearest_player(pos, 28)", self.mobs)

    def test_food_api(self):
        self.assertIn("function novaterra_survival.feed(player, amount)", self.survival)
        self.assertIn("data.hunger >= MAX_HUNGER", self.survival)
        self.assertIn("novaterra_survival.feed(user, 8)", self.mobs)

    def test_dependencies(self):
        self.assertIn("depends = nv_core, nv_world, nv_survival", self.config)

if __name__ == "__main__":
    unittest.main()
