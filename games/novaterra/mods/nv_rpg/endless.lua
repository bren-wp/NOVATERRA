-- Deterministic, persistent, repeatable objectives for unlimited offline play.
-- Every completed tier scales its goal; progress is stored in player metadata.
local M = {}
local TYPES = {
  wood = {title = "Woodcutter", base = 24, step = 8, xp = 55},
  stone = {title = "Stonebreaker", base = 32, step = 12, xp = 70},
  ore = {title = "Deep Miner", base = 10, step = 4, xp = 100},
  craft = {title = "Artisan", base = 2, step = 1, xp = 75},
  hunter = {title = "Night Guardian", base = 6, step = 2, xp = 120},
}
M.order = {"wood", "stone", "ore", "craft", "hunter"}
M.definitions = TYPES
local function prefix(id) return "nv_endless_" .. id .. "_" end
local function clamp_tier(value)
  return math.max(1, math.min(100000, math.floor(value)))
end
function M.goal(id, tier)
  local def = TYPES[id]
  if not def then return nil end
  return def.base + (clamp_tier(tier) - 1) * def.step
end
function M.state(player, id)
  if not TYPES[id] then return nil end
  local meta = player:get_meta()
  local tier = clamp_tier(meta:get_int(prefix(id) .. "tier"))
  local goal = M.goal(id, tier)
  local progress = math.max(0, math.min(goal - 1, meta:get_int(prefix(id) .. "progress")))
  return {tier = tier, progress = progress, goal = goal, title = TYPES[id].title}
end
function M.record(player, id, amount)
  if not player or not player:is_player() or not TYPES[id] then return 0 end
  if type(amount) ~= "number" or amount ~= amount or amount < 1 or amount > 100 then return 0 end
  local meta = player:get_meta()
  local state = M.state(player, id)
  local remaining = math.floor(amount)
  local xp = 0
  while remaining > 0 do
    local to_goal = state.goal - state.progress
    local used = math.min(remaining, to_goal)
    state.progress = state.progress + used
    remaining = remaining - used
    if state.progress == state.goal then
      xp = xp + TYPES[id].xp + math.min(state.tier - 1, 1000) * 5
      state.tier = math.min(state.tier + 1, 100000)
      state.goal = M.goal(id, state.tier)
      state.progress = 0
    end
  end
  meta:set_int(prefix(id) .. "tier", state.tier)
  meta:set_int(prefix(id) .. "progress", state.progress)
  return xp
end
return M
