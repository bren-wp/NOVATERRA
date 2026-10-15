from pathlib import Path
root=Path(__file__).resolve().parents[1]/'games'/'novaterra'/'mods'
ui=(root/'nv_ui'/'init.lua').read_text()
survival=(root/'nv_survival'/'init.lua').read_text()
assert "local SETTINGS = 'nv_ui:settings'" in ui
assert "formname == SETTINGS and fields.hud_visible" in ui
assert "novaterra_survival.set_hud_visible(player, visible)" in ui
assert "function novaterra_survival.set_hud_visible(player, visible)" in survival
assert "core.register_on_respawnplayer" in survival
print('v0.6.0 UI and HUD integration contracts: OK')
