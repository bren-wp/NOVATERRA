"""Limit the pinned Luanti Android application to NOVATERRA offline worlds.

Only the interactive main menu is changed: the C++/OpenGL ES runtime and its
embedded singleplayer server are retained. There are no external game servers.
The Android INTERNET permission remains because the native engine uses local
network sockets internally; it is not evidence of an external backend.
"""
from __future__ import annotations

from pathlib import Path


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

    # No public server browser, online ContentDB tab, or update request.
    # Loading the internal tab modules is harmless; none are selectable.
    main = replace_once(original, "\ttv_main:add(tabs.play_online)\n",
                        "\t-- NOVATERRA offline: online servers are unavailable.\n", "init.lua")
    main = replace_once(main, "\ttv_main:add(tabs.content)\n",
                        "\t-- NOVATERRA offline: no content downloads.\n", "init.lua")
    main = replace_once(main, "\tcheck_new_version()\n",
                        "\t-- NOVATERRA offline: update polling disabled.\n", "init.lua")
    main = replace_once(main, '\tlocal last_tab = core.settings:get("maintab_LAST")',
                        '\tlocal last_tab = "local"', "init.lua")

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
        'core.settings:set_bool("contentdb_enable_updates_indicator", false)\n'
        'local menupath = core.get_mainmenu_path()',
        "init.lua",
    )
    # Branded, touch-friendly singleplayer menu styling; no fake controls.
    local = replace_once(
        local,
        '\tlocal retval = ""',
        '''\tlocal retval = table.concat({
        "box[0.0,0.0;15.5,7.1;#0C1923E9]",
        "box[0.18,0.18;15.1,0.11;#C9A060]",
        "style_type[button;bgcolor=#1D3C34;bgcolor_hovered=#316A48;bgcolor_pressed=#123526;textcolor=#FFFFFF;border=false]",
        "style[play;bgcolor=#418F4D;bgcolor_hovered=#52A861;textcolor=#FFFFFF]",
        "label[0.4,6.33;NOVATERRA / OFFLINE ADVENTURE]",
    })''',
        "tab_local.lua",
    )
    local = replace_once(local, 'caption = fgettext("Start Game")',
                         'caption = "NOVATERRA"', "tab_local.lua")
    local = replace_once(local, 'fgettext("Play Game")',
                         '"IGRAJ / NASTAVI"', "tab_local.lua")
    local = replace_once(local, 'fgettext("Select World:")',
                         '"MOJI SVJETOVI"', "tab_local.lua")
    local = replace_once(local, 'fgettext("New")',
                         '"NOVI SVIJET"', "tab_local.lua")

    init_file.write_text(main, encoding="utf-8")
    local_file.write_text(local, encoding="utf-8")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("luanti", type=Path)
    patch_offline_mainmenu(parser.parse_args().luanti)
