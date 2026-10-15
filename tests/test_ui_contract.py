"""Static UI contract checks, not a runtime Luanti test."""
from pathlib import Path
s = (Path(__file__).resolve().parents[1] / 'games/novaterra/mods/nv_ui/init.lua').read_text()
for token in ('register_chatcommand(\'novaterra\'', 'register_on_player_receive_fields', 'formspec_version[4]', 'fields.back', 'fields.guide', 'fields.controls', 'core.formspec_escape'):
    assert token in s, token
assert 'os.execute' not in s and 'loadstring' not in s
print('UI static contract: PASS')
