"""Brand Luanti's Android main menu while preserving native world handlers.

The stock world-selection formspec is replaced wholesale instead of mutating
its button coordinates. This keeps the UI comprehensible and avoids dead
legacy layout fragments. Luanti still owns world creation, play and deletion.
"""
from __future__ import annotations

from pathlib import Path
import shutil


def replace_once(text: str, old: str, new: str, source: str) -> str:
    count = text.count(old)
    if count != 1:
        raise ValueError(f"Offline patch incompatible with {source}: {old!r}, count={count}")
    return text.replace(old, new, 1)


def patch_offline_mainmenu(engine: Path) -> None:
    menu_dir = engine / "builtin" / "mainmenu"
    init_file = menu_dir / "init.lua"
    tab_file = menu_dir / "tab_local.lua"

    for filename in ("novaterra_home.lua", "novaterra_world_details.lua", "novaterra_worlds.lua"):
        shutil.copyfile(Path(__file__).with_name(filename), menu_dir / filename)

    main = init_file.read_text(encoding="utf-8")
    for tab in ("play_online", "content", "about"):
        main = replace_once(
            main, f"\ttv_main:add(tabs.{tab})\n",
            f"\t-- NOVATERRA offline: {tab} tab unavailable.\n", "init.lua"
        )
    main = replace_once(main, "\tcheck_new_version()\n",
                        "\t-- NOVATERRA offline: update polling disabled.\n", "init.lua")
    main = replace_once(main, '\tlocal last_tab = core.settings:get("maintab_LAST")',
                        '\tlocal last_tab = "local"', "init.lua")
    main = replace_once(
        main, "local menupath = core.get_mainmenu_path()",
        'core.settings:set_bool("enable_server", false)\n'
        'core.settings:set_bool("server_announce", false)\n'
        'core.settings:set("serverlist_url", "")\n'
        'core.settings:set_bool("contentdb_enable_updates_indicator", false)\n'
        'core.get_http_api = nil\n'
        'local menupath = core.get_mainmenu_path()\n'
        'novaterra_world_details = dofile(menupath .. DIR_DELIM .. "novaterra_world_details.lua")\n'
        'novaterra_home = dofile(menupath .. DIR_DELIM .. "novaterra_home.lua")\n'
        'novaterra_worlds = dofile(menupath .. DIR_DELIM .. "novaterra_worlds.lua")',
        "init.lua",
    )
    # Remove the user-visible upstream debug banner; retain actual debug logs
    # and the true signing metadata in all published development releases.
    debug_banner = (
        '\t-- Permanent warning if on an unoptimized debug build\n'
        '\tif core.is_debug_build() then\n'
        '\t\tlocal set_topleft_text = core.set_topleft_text\n'
        '\t\tcore.set_topleft_text = function(s)\n'
        '\t\t\ts = (s or "") .. "\\n"\n'
        '\t\t\ts = s .. core.colorize("#f22", core.gettext("Debug build, expect worse performance"))\n'
        '\t\t\tset_topleft_text(s)\n'
        '\t\tend\n'
        '\tend\n\n'
    )
    if debug_banner in main:
        main = replace_once(main, debug_banner, "", "init.lua")

    # No engine-level generic settings shortcut: NOVATERRA Home and Worlds
    # already expose their actual working settings buttons.
    default_settings_button = '''\ttv_main:set_end_button({
\t\ticon = defaulttexturedir .. "settings_btn.png",
\t\tlabel = fgettext("Settings"),
\t\tname = "open_settings",
\t\ton_click = function(tabview)
\t\t\tlocal dlg = create_settings_dlg()
\t\t\tdlg:set_parent(tabview)
\t\t\ttabview:hide()
\t\t\tdlg:show()
\t\t\treturn true
\t\tend,
\t})
'''
    if default_settings_button in main:
        main = replace_once(main, default_settings_button,
                            '\t-- NOVATERRA settings are available in branded screens.\n',
                            "init.lua")
    init_file.write_text(main, encoding="utf-8")

    local = tab_file.read_text(encoding="utf-8")
    local = replace_once(
        local,
        '\tbtnbar:add_button("game_open_cdb", "", plus_image, fgettext("Install games from ContentDB"))\n',
        '\t-- NOVATERRA: no online game catalog.\n',
        "tab_local.lua",
    )
    # Remove the entire stock form, including Host Game and the old button
    # offsets. The native callback function below remains unchanged except
    # for branded Home/Worlds navigation fields.
    begin = "local function get_formspec(tabview, name, tabdata)\n"
    boundary = "\nlocal function main_button_handler(this, fields, name, tabdata)\n"
    if local.count(begin) != 1 or local.count(boundary) != 1:
        raise ValueError("Unexpected Luanti tab_local.lua get_formspec structure")
    prefix, tail = local.split(begin, 1)
    old_form, handler = tail.split(boundary, 1)
    if not old_form.strip():
        raise ValueError("Refusing to remove an empty world form")
    replacement = '''local function get_formspec(tabview, name, tabdata)
    if tabdata.nv_view == "worlds" then
        return novaterra_worlds.formspec()
    end
    local game = current_game()
    local logo = game and game.path and
      (game.path .. DIR_DELIM .. "menu" .. DIR_DELIM .. "logo.png") or ""
    return novaterra_home.formspec(logo)
end
'''
    local = prefix + replacement + boundary + handler

    handler_start = '\tassert(name == "local")'
    branded_navigation = '''\tassert(name == "local")
    if fields.nv_worlds then
        tabdata.nv_view = "worlds"
        return true
    end
    if fields.nv_back_home then
        tabdata.nv_view = "home"
        return true
    end
    if fields.nv_new then
        tabdata.nv_view = "worlds"
        fields.world_create = true
    end
    if fields.nv_continue then
        if novaterra_home.resume() then return true end
        tabdata.nv_view = "worlds"
        return true
    end
    if fields.nv_settings then
        local settings = create_settings_dlg()
        settings:set_parent(this)
        this:hide()
        settings:show()
        return true
    end
    if fields.nv_exit then
        core.close()
        return true
    end
    if fields.nv_world_info then
        local listing = menudata.worldlist
        local index = core.get_textlist_index("sp_worlds")
        if index and index > 0 then
            local worlds = listing:get_list()
            local world = worlds and worlds[index]
            if world then
                local dlg = novaterra_world_details.create_dialog(world)
                if dlg then
                    dlg:set_parent(this)
                    this:hide()
                    dlg:show()
                end
            end
        end
        return true
    end'''
    local = replace_once(local, handler_start, branded_navigation, "tab_local.lua")

    # The native gamebar and ContentDB helper are irrelevant in a bundled
    # one-game Android build; do not create or show any phantom game icon row.
    old_gamebar = '''\t\tif singleplayer_refresh_gamebar() then
\t\t\tui.find_by_name("game_button_bar"):show()
\t\tend'''
    if old_gamebar in local:
        local = replace_once(local, old_gamebar,
                             '\t\t-- NOVATERRA uses its own world-navigation screens.',
                             "tab_local.lua")
    # There is just one actual tab; its label is our game title.
    local = replace_once(local, 'caption = fgettext("Start Game")',
                         'caption = "NOVATERRA"', "tab_local.lua")
    tab_file.write_text(local, encoding="utf-8")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("luanti", type=Path)
    patch_offline_mainmenu(parser.parse_args().luanti)
