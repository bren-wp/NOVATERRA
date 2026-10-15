from pathlib import Path
root = Path(__file__).resolve().parents[1] / 'games/novaterra/mods'
core = (root / 'nv_core/init.lua').read_text()
ui = (root / 'nv_ui/init.lua').read_text()
survival = (root / 'nv_survival/init.lua').read_text()
assert 'register_decoration' in core
assert 'register_on_generated' not in core
assert 'show_inventory(player)' in ui
assert 'player:get_inventory_formspec()' in ui
assert "fields.inventory then\n    show_inventory(player)" in ui
assert "register_chatcommand('nvhud'" in survival
assert 'nv_hide_hud' in survival
print('v0.5.0 static regression contracts: PASS')
