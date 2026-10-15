-- Executes the survival module against a fake server/player and checks HUD behavior.
local joined, stepped, craftItems = nil, nil, {}
local elements = {}
local hp = 16
local metadata = {nv_hunger_initialized = 1, nv_hunger = 12}
local meta = {
  get_int = function(_, key) return metadata[key] or 0 end,
  set_int = function(_, key, value) metadata[key] = value end,
}
local player = {
  get_player_name = function() return 'NovaterraTester' end,
  is_player = function() return true end,
  get_meta = function() return meta end,
  get_hp = function() return hp end,
  get_pos = function() return {x = 8, y = 32, z = -5} end,
  get_properties = function() return {hp_max = 20} end,
  hud_add = function(_, definition)
    elements[#elements + 1] = definition
    return #elements
  end,
  hud_change = function(_, id, property, value)
    assert(elements[id], 'Unknown HUD element')
    elements[id][property] = value
  end,
}
core = {
  register_craftitem = function(name, def) craftItems[name] = def end,
  register_craft = function() end,
  register_on_joinplayer = function(fn) joined = fn end,
  register_on_leaveplayer = function() end,
  register_on_dieplayer = function() end,
  register_on_respawnplayer = function() end,
  register_chatcommand = function() end,
  register_globalstep = function(fn) stepped = fn end,
  get_connected_players = function() return {player} end,
}
dofile('games/novaterra/mods/nv_survival/init.lua')
assert(joined and stepped, 'Survival callbacks not registered')
joined(player)
assert(elements[1].hud_elem_type == 'statbar')
assert(elements[2].hud_elem_type == 'statbar')
assert(elements[1].text == 'nv_health_full.png')
assert(elements[2].text == 'nv_hunger_full.png')
assert(elements[1].number == 16)
assert(elements[2].number == 12)
assert(elements[3].hud_elem_type == 'text')
-- A recent health change must be visible in under 1 second.
hp = 11
stepped(0.6)
assert(elements[1].number == 11, 'Health HUD update is not responsive')
novaterra_survival.set_hud_visible(player, false)
assert(elements[1].number == 0 and elements[1].text == '')
assert(elements[2].number == 0 and elements[2].text == '')
novaterra_survival.set_hud_visible(player, true)
assert(elements[1].number == 11)
assert(elements[2].number == 12)
novaterra_survival.set_coordinates_visible(player, true)
assert(elements[3].text:find('X 8', 1, true))
assert(novaterra_survival.feed(player, 6))
assert(elements[2].number == 18)
assert(not novaterra_survival.feed(player, 6))
print('NOVATERRA survival statbars, touch HUD and server-side hunger: PASS')
