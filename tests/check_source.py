"""Lightweight packaging checks; these do not replace engine/device tests."""
from pathlib import Path
import struct
ROOT = Path(__file__).resolve().parents[1]
game = ROOT / 'games' / 'novaterra'
assert (game / 'game.conf').exists()
for name in ('nv_core','nv_survival','nv_ui'):
    folder = game / 'mods' / name
    assert (folder / 'init.lua').exists()
    assert (folder / 'mod.conf').exists()
    assert (folder / 'init.lua').stat().st_size > 100
for path in (game / 'mods').rglob('*.png'):
    content = path.read_bytes()
    assert content[:8] == b'\x89PNG\r\n\x1a\n', path
    width,height = struct.unpack('>II',content[16:24])
    assert 0 < width <= 4096 and 0 < height <= 4096, path
print('NOVATERRA source structure and PNG headers: PASS')
