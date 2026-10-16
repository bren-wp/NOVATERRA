-- Real Lua 5.1 exercise of the Android-only touch-first formspec builder.
local function assert_contains(value, term)
  assert(value:find(term, 1, true), 'Missing expected UI element: ' .. term)
end

core = { formspec_escape = function(v)
  return tostring(v):gsub('\\', '\\\\'):gsub('%]', '\\]'):gsub('%[', '\\[')
end }
novaterra_rpg = {
  get_xp = function() return 225 end,
  get_level = function() return 2 end,
}
local data = {
  nv_hunger = 12,
  nv_hunger_initialized = 1,
  nv_hide_hud = 0,
  nv_show_coordinates = 1,
  nv_classic_ui = 0,
}
local meta = {
  get_int = function(_, key) return data[key] or 0 end,
}
local player = {
  get_hp = function() return 15 end,
  get_properties = function() return {hp_max = 20} end,
  get_meta = function() return meta end,
  get_pos = function() return {x = 128.9, y = 71.2, z = -304.4} end,
}
local menu = dofile('games/novaterra/mods/nv_ui/mobile.lua')
local hub = menu.hub(player)
for _, token in ipairs({
  'formspec_version[4]', 'NOVATERRA', 'NASTAVI', 'INVENTORY',
  'VODIC ZA PREZIVLJAVANJE', 'KARTA / LOKACIJE',
  'ZADACI I POSTIGNUCA', 'KONTROLE', 'POSTAVKE',
  'style[resume;bgcolor=#388B48',
  'ZDRAVLJE  15 / 20', 'HRANA  12 / 20',
  'RAZINA  2   /   225 XP', 'X 128   Y 71   Z -305',
}) do
  assert_contains(hub, token)
end
for _, item in ipairs({'resume', 'inventory', 'guide', 'map', 'quests', 'settings', 'controls'}) do
  assert_contains(hub, ';' .. item .. ';')
end
local guide = menu.guide()
assert_contains(guide, 'SAKUPI DRVO')
assert_contains(guide, ';back;')
local controls = menu.controls()
assert_contains(controls, 'ANDROID')
assert(not controls:find('WINDOWS', 1, true))
assert_contains(controls, 'IZRADA I ISTRAZIVANJE')
local settings = menu.settings(player)
for _, flag in ipairs({'hud_visible;', 'coordinates_visible;', 'mobile_interface;'}) do
  assert_contains(settings, flag)
end
assert_contains(settings, 'mobile_interface;Koristi velike mobilne gumbe;true')
data.nv_classic_ui = 1
settings = menu.settings(player)
assert_contains(settings, 'mobile_interface;Koristi velike mobilne gumbe;false')
print('NOVATERRA mobile formspec functional unit test: PASS')
