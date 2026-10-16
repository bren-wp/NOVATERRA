"""Static UI contract checks, not a runtime Luanti test."""
from pathlib import Path
s = (Path(__file__).resolve().parents[1] / 'games/novaterra/mods/nv_ui/init.lua').read_text()
for token in ('register_chatcommand(\'novaterra\'', 'register_on_player_receive_fields', 'formspec_version[4]', 'fields.back', 'fields.guide', 'fields.controls', 'core.formspec_escape'):
    assert token in s, token
assert 'os.execute' not in s and 'loadstring' not in s
for forbidden in (
    "Luanti touch controls.",
    "NOVATERRA / SURVIVAL WORLD",
    "ANDROID: use the Luanti",
    "BACK TO MENU]",
    "button[0.8,3.15;4.4,0.85;inventory;INVENTORY]",
    "core.chat_send_player(name",
    "core.after(0.7",
):
    assert forbidden not in s, f"Player-facing engine or technical onboarding copy: {forbidden}"
assert "on_joinplayer" in s and "nv_mobile_intro_shown" in s
assert "nv_ui:field_manual" in s
print('UI static contract: PASS')
