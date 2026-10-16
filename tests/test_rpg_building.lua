-- Integration regression: placed solid blocks advance persistent endless builder goals.
local placed, notifications = nil, {}
local state = {}
local meta = {
  get_int = function(_, key) return state[key] or 0 end,
  set_int = function(_, key, value) state[key] = value end,
}
local player = {
  get_meta = function() return meta end,
  is_player = function() return true end,
  get_player_name = function() return "BuilderTester" end,
}
core = {
  get_modpath = function() return "games/novaterra/mods/nv_rpg" end,
  register_on_dignode = function() end,
  register_on_placenode = function(callback) placed = callback end,
  register_on_craft = function() end,
  register_on_player_receive_fields = function() end,
  register_chatcommand = function() end,
  register_on_joinplayer = function() end,
  formspec_escape = function(s) return s end,
  chat_send_player = function(_, message) notifications[#notifications + 1] = message end,
  registered_nodes = {
    ["nv_core:cobble"] = {},
    ["nv_core:torch"] = {walkable = false},
    ["external:brick"] = {},
  },
}
dofile("games/novaterra/mods/nv_rpg/init.lua")
assert(placed, "Missing builder node-placement callback")
local valid = {name = "nv_core:cobble"}
local current = function() return novaterra_rpg.endless_state(player, "builder") end
assert(current().tier == 1 and current().progress == 0)
placed({}, {name = "nv_core:torch"}, player)
placed({}, {name = "external:brick"}, player)
placed({}, valid, nil)
assert(current().progress == 0, "Invalid placement generated builder progress")
assert(novaterra_rpg.add_event(player, "builder", -1) == false)
assert(novaterra_rpg.add_event(player, "builder", 0/0) == false)
assert(novaterra_rpg.add_event(player, "builder", 1.5) == false)
assert(current().progress == 0, "Invalid event generated builder progress")
for i = 1, 40 do placed({}, valid, player) end
assert(current().tier == 2 and current().progress == 0, "Building tier was not completed")
assert(novaterra_rpg.get_xp(player) == 85, "Builder XP was not credited exactly once")
assert(state["nv_endless_builder_tier"] == 2, "Builder tier was not saved to player metadata")
placed({}, valid, player)
assert(current().progress == 1, "Next-tier builder progress did not continue")
assert(novaterra_rpg.get_xp(player) == 85, "Builder XP duplicated after completion")
assert(#notifications == 1, "Expected exactly one builder completion notification")
print("NOVATERRA Android endless building events and local persistence: PASS")
