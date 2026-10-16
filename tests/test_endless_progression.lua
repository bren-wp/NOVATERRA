-- Lua 5.1 integration tests for persistent repeatable Android offline quests.
local M = dofile("games/novaterra/mods/nv_rpg/endless.lua")
local store = {}
local meta = {
  get_int = function(_, key) return store[key] or 0 end,
  set_int = function(_, key, value) store[key] = value end,
}
local player = {is_player = function() return true end, get_meta = function() return meta end}
assert(M.goal("wood", 1) == 24)
assert(M.goal("wood", 2) == 32)
assert(M.goal("builder", 1) == 40)
assert(M.goal("builder", 2) == 56)
assert(M.goal("unknown", 1) == nil)
assert(M.record(player, "wood", 23) == 0)
local state = M.state(player, "wood")
assert(state.tier == 1 and state.progress == 23 and state.goal == 24)
local reward = M.record(player, "wood", 1)
assert(reward == 55)
state = M.state(player, "wood")
assert(state.tier == 2 and state.progress == 0 and state.goal == 32)
assert(M.record(player, "wood", 32) == 60)
state = M.state(player, "wood")
assert(state.tier == 3 and state.progress == 0)
assert(M.record(player, "wood", 100) > 0)
assert(M.state(player, "wood").tier >= 5)
assert(M.record(player, "wood", -1) == 0)
assert(M.record(player, "wood", 100000) == 0)
assert(M.record(player, "invalid", 1) == 0)
assert(M.record(player, "builder", 39) == 0)
assert(M.state(player, "builder").progress == 39)
assert(M.record(player, "builder", 1) == 85)
assert(M.state(player, "builder").tier == 2)
-- Recreate player handle while preserving the same local metadata store.
local resumed = {is_player = function() return true end, get_meta = function() return meta end}
assert(M.state(resumed, "builder").tier == 2)
assert(M.state(resumed, "builder").progress == 0)
assert(M.record(resumed, "builder", 3) == 0)
assert(M.state(player, "builder").progress == 3)
assert(M.record(nil, "wood", 1) == 0)
print("NOVATERRA endless offline progression: PASS")
