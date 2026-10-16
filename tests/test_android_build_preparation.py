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
        shutil.copytree(ROOT / "res", self.project / "res")
        mainmenu = self.engine / "builtin/mainmenu"
        mainmenu.mkdir(parents=True)
        (mainmenu / "init.lua").write_text(
            'local menupath = core.get_mainmenu_path()\n'
            '\ttv_main:add(tabs.local_game)\n'
            '\ttv_main:add(tabs.play_online)\n'
            '\ttv_main:add(tabs.content)\n'
            '\ttv_main:add(tabs.about)\n'
            '\tlocal last_tab = core.settings:get("maintab_LAST")\n'
            '\tcheck_new_version()\n',
            encoding="utf-8",
        )
        (mainmenu / "tab_local.lua").write_text(
            '\tbtnbar:add_button("game_open_cdb", "", plus_image, fgettext("Install games from ContentDB"))\n'
            'local function get_formspec(tabview, name, tabdata)\n'
            '\tlocal retval = ""\n'
            '\t\t\t"container[0.375,0.375]" ..\n\t\t\tcreative ..\n'
            'fgettext("Delete") fgettext("Select Mods") fgettext("Creative Mode") fgettext("Enable Damage")\n'
            '\tcaption = fgettext("Start Game"),\n'
            '\tlabel[0,0.2; .. fgettext("Select World:") .. ]\n'
            '\t"button[10.1875,5.925;4.9375,0.8;play;" .. fgettext("Play Game") .. "]"\n'
            '\t"button[6.65,0;3.225,0.8;world_create;" .. fgettext("New") .. "]"\n'
            '\treturn retval\n'
            'end\n\n'
            'local function main_button_handler(this, fields, name, tabdata)\n'            '\tassert(name == "local")\n'

            '\tif fields["world_create"] ~= nil then\n'
            '\t\treturn true\n'
            '\tend\n'
            'end\n',
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
        (main / "res/values").mkdir(parents=True, exist_ok=True)
        styles = main / "res/values/styles.xml"
        styles.write_text('<item name="android:windowBackground">@drawable/bg</item>', encoding="utf-8")
        strings = main / "res/values/strings.xml"
        strings.parent.mkdir(parents=True, exist_ok=True)
        strings.write_text('<string name="label">Luanti</string>', encoding="utf-8")

    def test_embedded_game_and_android_brand(self):
        self.preparer.prepare(self.engine, self.project)
        gradle = (self.engine / "android/app/build.gradle").read_text()
        self.assertIn("applicationId 'com.brendigo.novaterra'", gradle)
        self.assertIn("include 'arm64-v8a'", gradle)
        self.assertIn("games/novaterra", gradle)
        self.assertIn("novaterra-mobile.conf", gradle)
        self.assertEqual(self.preparer.VERSION_NAME, "0.0.7")
        self.assertEqual(self.preparer.VERSION_CODE, 20007)
        self.assertIn('versionName "0.0.7"', gradle)
        self.assertIn("versionCode " + str(self.preparer.VERSION_CODE), gradle)
        game = self.engine / "games/novaterra"
        self.assertEqual(len(list(game.rglob("*.png"))), 23)
        background = (game / "menu/background.png").read_bytes()
        self.assertEqual(background[:8], b"\x89PNG\r\n\x1a\n")
        self.assertEqual(__import__("struct").unpack(">II", background[16:24]), (1440, 810))
        logo = (game / "menu/logo.png").read_bytes()
        self.assertEqual(logo[:8], b"\\x89PNG\\r\\n\\x1a\\n")
        self.assertEqual(__import__("struct").unpack(">II", logo[16:24]), (880, 210))
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
        self.assertTrue((main / "res/drawable/novaterra_landscape.xml").is_file())
        self.assertTrue((main / "res/drawable-land/novaterra_landscape.xml").is_file())
        self.assertIn('<item name="android:windowBackground">#091820</item>',
                      (main / "res/values/styles.xml").read_text())
        splash = (main / "res/layout/activity_main.xml").read_text(encoding="utf-8")
        self.assertIn("@drawable/novaterra_landscape", splash)
        self.assertIn('android:scaleType="centerCrop"', splash)
        self.assertIn('android:text="TVOJ SVIJET. BEZ GRANICA."', splash)

    def test_offline_menu_disables_online_server_and_content_browser(self):
        self.preparer.prepare(self.engine, self.project)
        menu = (self.engine / "builtin/mainmenu/init.lua").read_text(encoding="utf-8")
        local = (self.engine / "builtin/mainmenu/tab_local.lua").read_text(encoding="utf-8")
        self.assertNotIn("tv_main:add(tabs.play_online)", menu)
        self.assertNotIn("tv_main:add(tabs.content)", menu)
        self.assertNotIn("check_new_version()", menu)
        self.assertIn('core.settings:set_bool("enable_server", false)', menu)
        self.assertIn('core.settings:set("serverlist_url", "")', menu)
        self.assertIn("core.get_http_api = nil", menu)
        self.assertNotIn('btnbar:add_button("game_open_cdb"', local)
        self.assertIn("GRADI SVOJU PRICU", local)
        self.assertNotIn("SOLO / OFFLINE / ANDROID", local)
        self.assertNotIn("OFFLINE ADVENTURE", local)
        self.assertIn(";nv_settings;POSTAVKE", local)
        self.assertIn(";nv_back_home;NATRAG", local)
        home = (self.engine / "builtin/mainmenu/novaterra_home.lua").read_text(encoding="utf-8")
        self.assertIn(";nv_exit;IZLAZ", home)
        self.assertIn("create_settings_dlg()", local)
        self.assertIn("core.close()", local)
        details = (self.engine / "builtin/mainmenu/novaterra_world_details.lua").read_text(encoding="utf-8")
        self.assertIn("novaterra_world_details = dofile(", menu)
        self.assertIn("nv_world_info", local)
        self.assertIn("novaterra_home = dofile(", menu)
        self.assertIn("nv_view", local)
        self.assertIn("novaterra_home.formspec(path)", local)
        self.assertIn("novaterra_home.resume()", local)
        self.assertIn("nv_back_home", local)
        self.assertIn("fields[\"nv_worlds\"]", local)
        self.assertIn("fields[\"nv_new\"]", local)
        self.assertIn("fields[\"nv_continue\"]", local)
        self.assertTrue((self.engine / "builtin/mainmenu/novaterra_home.lua").is_file())
        self.assertIn("novaterra_world_details.create_dialog(world)", local)
        self.assertIn("fixed_map_seed", details)
        self.assertIn("mg_name", details)
        self.assertIn("creative_mode", details)
        self.assertIn("enable_damage", details)
        self.assertNotIn("core.delete_world(", details)
        self.assertIn("TVOJ SVIJET.", local)
        self.assertIn("BEZ GRANICA.", local)
        self.assertIn("ODABIR SVIJETA", local)
        self.assertIn("style[world_create;", local)
        self.assertIn("style[world_delete;", local)
        self.assertIn("POSTAVKE SVIJETA", local)
        self.assertIn("OBRISI SVIJET", local)
        self.assertIn('"container[10.25,5.60]"', local)
        self.assertNotIn("tv_main:add(tabs.about)", menu)
        self.assertIn("world_create", local)
        self.assertIn("world_delete", local)
        self.assertIn("style[play;bgcolor=#398E45", local)
        self.assertIn("IGRAJ / NASTAVI", local)
        self.assertIn("NOVI SVIJET", local)
        self.assertNotIn('caption = fgettext("Start Game")', local)
        game_conf = (self.engine / "games/novaterra/game.conf").read_text(encoding="utf-8")
        self.assertIn("disabled_settings = enable_server", game_conf)



if __name__ == "__main__":
    unittest.main()
