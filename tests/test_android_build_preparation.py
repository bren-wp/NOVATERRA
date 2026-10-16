"""Test the actual Android build-preparation script against a Luanti-shaped fixture."""
import importlib.util
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "prepare-luanti.py"
sys.path.insert(0, str(ROOT))

class AndroidPrepTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        spec = importlib.util.spec_from_file_location("nv_android_prepare", SCRIPT)
        cls.preparer = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.preparer)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.project = root / "project"
        self.engine = root / "luanti"
        shutil.copytree(ROOT / "games" / "novaterra", self.project / "games" / "novaterra")
        shutil.copytree(ROOT / "res", self.project / "android" / "res")
        mainmenu = self.engine / "builtin/mainmenu"
        mainmenu.mkdir(parents=True)
        (mainmenu / "init.lua").write_text(
            'local menupath = core.get_mainmenu_path()\n'
            '\ttv_main:add(tabs.local_game)\n'
            '\ttv_main:add(tabs.play_online)\n'
            '\ttv_main:add(tabs.content)\n'
            '\tlocal last_tab = core.settings:get("maintab_LAST")\n'
            '\tcheck_new_version()\n',
            encoding="utf-8",
        )
        (mainmenu / "tab_local.lua").write_text(
            '\tbtnbar:add_button("game_open_cdb", "", plus_image, fgettext("Install games from ContentDB"))\n'
            '\tlocal retval = ""\n'
            '\tcaption = fgettext("Start Game"),\n'
            '\tlabel[0,0.2; .. fgettext("Select World:") .. ]\n'
            '\tbutton[play; .. fgettext("Play Game") .. ]\n'
            '\tbutton[world_create; .. fgettext("New") .. ]\n',
            encoding="utf-8",
        )
        gradle = self.engine / "android/app/build.gradle"
        gradle.parent.mkdir(parents=True)
        version = 'versionName "' + '$' + '{versionMajor}.' + '$' + '{versionMinor}.' + '$' + '{versionPatch}"'
        gradle.write_text("\n".join((
            "applicationId 'net.minetest.minetest'",
            version,
            "versionCode versionMajor * 1000000 + versionMinor * 10000 + versionPatch * 100 + versionBuild",
            "include 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'",
            'file("' + '$' + '{assetsFolder}/.nomedia").text = ""',
        )), encoding="utf-8")
        main = self.engine / "android/app/src/main"
        main.mkdir(parents=True)
        (main / "AndroidManifest.xml").write_text(
            'android:icon="@mipmap/ic_launcher" "net.minetest.minetest.fileprovider" "net.minetest.minetest.documents"',
            encoding="utf-8")
        java = main / "java/net/minetest/minetest/GameActivity.java"
        java.parent.mkdir(parents=True)
        java.write_text('"net.minetest.minetest.fileprovider" setSmallIcon(R.mipmap.ic_launcher)', encoding="utf-8")
        strings = main / "res/values/strings.xml"
        strings.parent.mkdir(parents=True)
        strings.write_text('<string name="label">Luanti</string>', encoding="utf-8")

    def test_embedded_game_and_android_brand(self):
        self.preparer.prepare(self.engine, self.project)
        gradle = (self.engine / "android/app/build.gradle").read_text()
        self.assertIn("applicationId 'com.brendigo.novaterra'", gradle)
        self.assertIn("include 'arm64-v8a'", gradle)
        self.assertIn("games/novaterra", gradle)
        self.assertIn("novaterra-mobile.conf", gradle)
        self.assertIn("versionCode " + str(self.preparer.VERSION_CODE), gradle)
        game = self.engine / "games/novaterra"
        self.assertEqual(len(list(game.rglob("*.png"))), 21)
        for mod in ("nv_core", "nv_world", "nv_survival", "nv_ui", "nv_mobs", "nv_rpg"):
            with self.subTest(mod=mod):
                self.assertTrue((game / "mods" / mod / "init.lua").is_file())

    def test_config_and_application_label(self):
        self.preparer.prepare(self.engine, self.project)
        config = (self.engine / "android/novaterra-mobile.conf").read_text()
        self.assertIn("hud_scaling = 0.9\n", config)
        self.assertIn("gui_scaling = 0.95\n", config)
        self.assertIn("menu_last_game = novaterra\n", config)
        self.assertIn("enable_server = false\n", config)
        self.assertIn("server_announce = false\n", config)
        self.assertIn("serverlist_url = \n", config)
        self.assertNotIn("name = NOVATERRA", config)
        self.assertNotIn("\\n", config)
        main = self.engine / "android/app/src/main"
        self.assertIn("com.brendigo.novaterra.fileprovider", (main / "AndroidManifest.xml").read_text())
        self.assertIn("com.brendigo.novaterra.documents", (main / "AndroidManifest.xml").read_text())
        self.assertIn("com.brendigo.novaterra.fileprovider", (main / "java/net/minetest/minetest/GameActivity.java").read_text())
        self.assertIn('<string name="label">NOVATERRA</string>', (main / "res/values/strings.xml").read_text())
        self.assertIn('android:icon="@drawable/novaterra_mark"', (main / "AndroidManifest.xml").read_text())
        self.assertIn('setSmallIcon(R.drawable.novaterra_mark)',
                      (main / "java/net/minetest/minetest/GameActivity.java").read_text())
        self.assertIn("NOVATERRA", (main / "res/layout/activity_main.xml").read_text())
        self.assertIn("@+id/progressBar", (main / "res/layout/activity_main.xml").read_text())
        self.assertIn("@+id/textView", (main / "res/layout/activity_main.xml").read_text())
        self.assertTrue((main / "res/drawable/novaterra_mark.xml").is_file())

    def test_offline_menu_disables_online_server_and_content_browser(self):
        self.preparer.prepare(self.engine, self.project)
        menu = (self.engine / "builtin/mainmenu/init.lua").read_text(encoding="utf-8")
        local = (self.engine / "builtin/mainmenu/tab_local.lua").read_text(encoding="utf-8")
        self.assertNotIn("tv_main:add(tabs.play_online)", menu)
        self.assertNotIn("tv_main:add(tabs.content)", menu)
        self.assertNotIn("check_new_version()", menu)
        self.assertIn('core.settings:set_bool("enable_server", false)', menu)
        self.assertIn('core.settings:set("serverlist_url", "")', menu)
        self.assertNotIn('btnbar:add_button("game_open_cdb"', local)
        self.assertIn("NOVATERRA / OFFLINE ADVENTURE", local)
        self.assertIn("style[play;bgcolor=#418F4D", local)
        self.assertIn("IGRAJ / NASTAVI", local)
        self.assertIn("NOVI SVIJET", local)
        self.assertNotIn('caption = fgettext("Start Game")', local)
        game_conf = (self.engine / "games/novaterra/game.conf").read_text(encoding="utf-8")
        self.assertIn("disabled_settings = enable_server", game_conf)



if __name__ == "__main__":
    unittest.main()
