"""Limit the pinned Luanti Android application to NOVATERRA offline worlds.

Only the interactive main menu is changed: the C++/OpenGL ES runtime and its
embedded singleplayer server are retained. There are no external game servers.
The Android INTERNET permission remains because the native engine uses local
network sockets internally; it is not evidence of an external backend.
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
    menu = engine / "builtin" / "mainmenu"
    init_file = menu / "init.lua"
    local_file = menu / "tab_local.lua"
    original = init_file.read_text(encoding="utf-8")
    # Use only local Luanti world records and read their world.mt files.
    shutil.copyfile(Path(__file__).with_name("novaterra_world_details.lua"),
                    menu / "novaterra_world_details.lua")

    # No public server browser, online ContentDB tab, or update request.
    # Loading the internal tab modules is harmless; none are selectable.
    main = replace_once(original, "\ttv_main:add(tabs.play_online)\n",
                        "\t-- NOVATERRA offline: online servers are unavailable.\n", "init.lua")
    main = replace_once(main, "\ttv_main:add(tabs.content)\n",
                        "\t-- NOVATERRA offline: no content downloads.\n", "init.lua")
    main = replace_once(main, "\ttv_main:add(tabs.about)\n",
                        "\t-- NOVATERRA-only menu: hide the generic engine About tab.\n", "init.lua")
    main = replace_once(main, "\tcheck_new_version()\n",
                        "\t-- NOVATERRA offline: update polling disabled.\n", "init.lua")
    main = replace_once(main, '\tlocal last_tab = core.settings:get("maintab_LAST")',
                        '\tlocal last_tab = "local"', "init.lua")

    # Register the read-only inspector before tab_local is constructed.
    main = replace_once(
        main, "local menupath = core.get_mainmenu_path()",
        'local menupath = core.get_mainmenu_path()\n'
        'novaterra_world_details = dofile(menupath .. DIR_DELIM .. "novaterra_world_details.lua")',
        "init.lua",
    )

    # Limit world management to singleplayer and disallow the ContentDB
    # shortcut. The NOVATERRA game.conf also disables hosting options.
    local = local_file.read_text(encoding="utf-8")
    local = replace_once(
        local,
        '\tbtnbar:add_button("game_open_cdb", "", plus_image, fgettext("Install games from ContentDB"))\n',
        "\t-- NOVATERRA offline: game download shortcut disabled.\n",
        "tab_local.lua",
    )
    # Ensure an old/stale preference cannot accidentally start hosting.
    main = replace_once(
        main,
        "local menupath = core.get_mainmenu_path()",
        'core.settings:set_bool("enable_server", false)\n'
        'core.settings:set_bool("server_announce", false)\n'
        'core.settings:set("serverlist_url", "")\n'
        'core.get_http_api = nil\n'
        'core.settings:set_bool("contentdb_enable_updates_indicator", false)\n'
        'local menupath = core.get_mainmenu_path()',
        "init.lua",
    )
    # Engine debugging remains available in logs; suppress only the stock
    # red main-menu overlay that is not part of NOVATERRA's player UI.
    debug_block = (
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
    if debug_block in main:
        main = replace_once(main, debug_block, "", "init.lua")

    # Branded, touch-friendly singleplayer menu styling; no fake controls.
    local = replace_once(
        local,
        '\tlocal retval = ""',
        '''\tlocal retval = table.concat({
        -- Real Luanti world operations are retained by their original field names.
        "box[0.00,0.00;15.5,7.1;#09151E60]",
        "box[0.18,0.18;4.68,6.65;#10252FB8]",
        "box[5.06,0.18;10.22,6.65;#142830BD]",
        "box[0.18,0.18;15.1,0.11;#C9A060]",
        "box[0.42,0.61;0.11,0.76;#65C970]",
        "style_type[button;bgcolor=#1D3540;bgcolor_hovered=#2E5660;bgcolor_pressed=#123526;textcolor=#FFFFFF;border=false]",
        "style[play;bgcolor=#398E45;bgcolor_hovered=#51AE5E;bgcolor_pressed=#216A32;textcolor=#FFFFFF]",
        "style[world_create;bgcolor=#328549;bgcolor_hovered=#4BA55D;textcolor=#FFFFFF]",
        "style[world_delete;bgcolor=#493235;bgcolor_hovered=#6B383D;textcolor=#FFF1E7]",
        "style[world_configure;bgcolor=#2A444A;bgcolor_hovered=#365D65;textcolor=#FFFFFF]",
        "label[0.68,0.73;NOVATERRA]",
        "label[0.55,1.53;BUILD / EXPLORE]",
        "label[0.55,1.92;SURVIVE / THRIVE]",
        "box[0.54,2.44;3.88,0.02;#A98853]",
        "label[0.55,2.65;TVOJ SVIJET.]",
        "label[0.55,3.10;BEZ GRANICA.]",
        "label[0.55,3.58;GRADI SVOJU PRICU]",
        "label[5.47,0.44;ODABIR SVIJETA]",
        "box[0.54,3.89;3.88,0.02;#A98853]",
    })''',
        "tab_local.lua",
    )
    # Keep both the built-in world list and its destructive confirmation dialog.
    # Move existing survival options below the branding rather than covering them.
    local = replace_once(
        local,
        '"container[0.375,0.375]" ..\n\t\t\tcreative ..',
        '"container[0.375,4.10]" ..\n\t\t\tcreative ..',
        "tab_local.lua",
    )
    for old, new in (
        ('fgettext("Delete")', '"OBRISI SVIJET"'),
        ('fgettext("Select Mods")', '"POSTAVKE SVIJETA"'),
        ('fgettext("Creative Mode")', '"KREATIVNI MOD"'),
        ('fgettext("Enable Damage")', '"SURVIVAL MOD"'),
    ):
        local = replace_once(local, old, new, "tab_local.lua")
    local = replace_once(local, 'caption = fgettext("Start Game")',
                         'caption = "NOVATERRA"', "tab_local.lua")
    local = replace_once(local, 'fgettext("Play Game")',
                         '"IGRAJ / NASTAVI"', "tab_local.lua")
    local = replace_once(local, 'fgettext("Select World:")',
                         '"MOJI SVJETOVI"', "tab_local.lua")
    local = replace_once(local, 'fgettext("New")',
                         '"NOVI SVIJET"', "tab_local.lua")

    # Add real world metadata without replacing Luanti's native world list,
    # world creation, confirmation before deletion or singleplayer launch.
    local = replace_once(
        local,
        "\treturn retval\nend\n\nlocal function main_button_handler",
        '''\tif world then
        retval = retval ..
            "button[5.34,5.925;4.58,0.8;nv_world_info;DETALJI SVIJETA]"
    end
    return retval
end

local function main_button_handler''',
        "tab_local.lua",
    )
    local = replace_once(
        local,
        '\tif fields["world_create"] ~= nil then',
        '''\tif fields["nv_world_info"] ~= nil then
        local selected = core.get_textlist_index("sp_worlds")
        local list = menudata.worldlist:get_list()
        local world = selected and list and list[selected]
        if world then
            local details = novaterra_world_details.create_dialog(world)
            if details then
                details:set_parent(this)
                this:hide()
                details:show()
            end
        end
        return true
    end

    if fields["world_create"] ~= nil then''',
        "tab_local.lua",
    )
    # Arrange genuine world actions in a left-side menu like the references.
    # Keep each upstream field id, confirmation handler and save lifecycle.
    local = replace_once(
        local,
        '"button[6.65,0;3.225,0.8;world_create;"',
        '"button[-4.70,0.02;3.92,0.70;world_create;"',
        "tab_local.lua",
    )
    local = replace_once(
        local,
        '"button[10.1875,5.925;4.9375,0.8;play;" .. "IGRAJ / NASTAVI"',
        '"button[0.55,4.06;3.92,0.70;play;" .. "IGRAJ / NASTAVI"',
        "tab_local.lua",
    )
    local = replace_once(
        local,
        "    return retval\nend\n\nlocal function main_button_handler",
        '''    retval = retval .. "button[0.55,5.68;3.92,0.59;nv_settings;POSTAVKE]"
    retval = retval .. "button[0.55,6.34;3.92,0.57;nv_exit;IZLAZ]"
    return retval
end

local function main_button_handler''',
        "tab_local.lua",
    )
    local = replace_once(
        local,
        '\tif fields["world_create"] ~= nil then',
        '''\tif fields["nv_settings"] ~= nil then
        local dlg = create_settings_dlg()
        dlg:set_parent(this)
        this:hide()
        dlg:show()
        return true
    end
    if fields["nv_exit"] ~= nil then
        core.close()
        return true
    end

    if fields["world_create"] ~= nil then''',
        "tab_local.lua",
    )
    # NOVATERRA bundles exactly one native game. Do not show the generic
    # Luanti multi-game selector below the main navigation.
    gamebar = '''\t\tif singleplayer_refresh_gamebar() then
\t\t\tui.find_by_name("game_button_bar"):show()
\t\tend'''
    if gamebar in local:
        local = replace_once(local, gamebar, '\t\t-- NOVATERRA singleplayer navigation', "tab_local.lua")

    init_file.write_text(main, encoding="utf-8")
    local_file.write_text(local, encoding="utf-8")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("luanti", type=Path)
    patch_offline_mainmenu(parser.parse_args().luanti)
