-- NOVATERRA RPG journal: persistent, server-authoritative challenges and XP.
local endless = dofile(core.get_modpath('nv_rpg') .. '/endless.lua')
local quests = {
  wood = {title="First Steps", detail="Gather 20 oak logs", goal=20, reward=75},
  stone = {title="Prospector", detail="Mine 32 stone blocks", goal=32, reward=100},
  ore = {title="Miner", detail="Discover 8 coal or iron ores", goal=8, reward=120},
  craft = {title="Craftsman", detail="Craft your first furnace", goal=1, reward=80},
  hunter = {title="Defender", detail="Defeat 5 hostile creatures", goal=5, reward=150},
}
local quest_order = {"wood", "stone", "ore", "craft", "hunter"}
local function key(name) return "nv_quest_" .. name end
local function progress(player, id)
  return player:get_meta():get_int(key(id))
end
local function experience(player)
  return player:get_meta():get_int("nv_rpg_xp")
end
local function level(player)
  -- Increasing XP requirements avoid reaching thousands of levels too quickly.
  local xp = math.max(0, experience(player))
  return math.floor((math.sqrt(1 + xp / 25) - 1) / 2) + 1
end
local function notify(player, message)
  core.chat_send_player(player:get_player_name(), "[NOVATERRA] " .. message)
end
local function award(player, id, amount)
  local def = quests[id]
  if not def or not player or not player:is_player() then return false end
  if type(amount) ~= "number" or amount < 1 or amount > 100 then return false end
  local meta = player:get_meta()
  local previous = progress(player, id)
  local repeat_xp = endless.record(player, id, amount)
  if repeat_xp > 0 then
    local old_level = level(player)
    meta:set_int("nv_rpg_xp", experience(player) + repeat_xp)
    notify(player, "Endless " .. endless.definitions[id].title .. " complete! +" .. repeat_xp .. " XP")
    if level(player) > old_level then notify(player, "LEVEL UP! " .. level(player)) end
  end
  if previous >= def.goal then return true end
  local current = math.min(def.goal, previous + math.floor(amount))
  meta:set_int(key(id), current)
  if current >= def.goal then
    local previous_level = level(player)
    meta:set_int("nv_rpg_xp", experience(player) + def.reward)
    notify(player, def.title .. " completed! +" .. def.reward .. " XP")
    if level(player) > previous_level then
      notify(player, "LEVEL UP! You are now level " .. level(player))
    end
  end
  return true
end

novaterra_rpg = {
  get_level = level,
  get_xp = experience,
  get_progress = progress,
  add_event = award,
  endless_state = endless.state,
  endless_order = endless.order,
}
function novaterra_rpg.record_defeat(player, kind)
  if kind == "crawler" or kind == "nightshade" then
    return award(player, "hunter", 1)
  end
  return false
end

core.register_on_dignode(function(pos, oldnode, digger)
  if not digger or not digger:is_player() then return end
  if oldnode.name == "nv_core:tree" then award(digger, "wood", 1)
  elseif oldnode.name == "nv_core:stone" then award(digger, "stone", 1)
  elseif oldnode.name == "nv_world:coal_ore" or oldnode.name == "nv_world:iron_ore" then
    award(digger, "ore", 1)
  end
end)
core.register_on_craft(function(itemstack, player)
  if player and player:is_player() and itemstack:get_name() == "nv_world:furnace" then
    award(player, "craft", 1)
  end
end)

local function show(player)
  local name = player:get_player_name()
  local title = "NOVATERRA / QUESTS & ACHIEVEMENTS"
  local parts = {
    "formspec_version[4]size[11,9.5]",
    "bgcolor[#0A141BF2;true]",
    "box[0.2,0.2;10.6,9.1;#142631E8]",
    "box[0.2,0.2;10.6,0.13;#CBA055]",
    "label[0.7,0.63;" .. title .. "]",
    "label[0.7,1.28;LEVEL " .. level(player) .. "   |   " .. experience(player) .. " XP]",
  }
  for i, id in ipairs(quest_order) do
    local def = quests[id]
    local current = progress(player, id)
    local y = 1.85 + (i - 1) * 1.22
    local completed = current >= def.goal
    parts[#parts + 1] = string.format("box[0.65,%.2f;9.7,1.07;%s]", y, completed and "#234535BB" or "#1B3541BB")
    parts[#parts + 1] = string.format("label[0.95,%.2f;%s]", y + 0.15, core.formspec_escape(def.title .. (completed and "  [COMPLETE]" or "")))
    parts[#parts + 1] = string.format("label[0.95,%.2f;%s]", y + 0.60, core.formspec_escape(def.detail))
    parts[#parts + 1] = string.format("label[8.32,%.2f;%d/%d]", y + 0.43, current, def.goal)
  end
  parts[#parts + 1] = "label[0.75,8.07;ENDLESS CHALLENGES / REPEATABLE GOALS]"
  parts[#parts + 1] = "button[7.5,8.1;2.8,0.6;endless;ENDLESS]"
  parts[#parts + 1] = "button_exit[4.2,8.65;2.6,0.65;close;BACK TO GAME]"
  core.show_formspec(name, "nv_rpg:quests", table.concat(parts))
end
local function show_endless(player)
  local parts = {
    "formspec_version[4]size[11,9.5]",
    "bgcolor[#0A141BF2;true]",
    "box[0.2,0.2;10.6,9.1;#142631E8]",
    "box[0.2,0.2;10.6,0.13;#CBA055]",
    "label[0.7,0.65;NOVATERRA / ENDLESS ADVENTURE]",
    "label[0.7,1.3;LEVEL " .. level(player) .. " / " .. experience(player) .. " XP]",
  }
  for i, id in ipairs(endless.order) do
    local state = endless.state(player, id)
    local y = 1.85 + (i - 1) * 1.15
    parts[#parts + 1] = string.format("box[0.65,%.2f;9.7,1.0;#1B3541BB]", y)
    parts[#parts + 1] = string.format("label[0.95,%.2f;%s / TIER %d]", y + 0.15, state.title, state.tier)
    parts[#parts + 1] = string.format("label[0.95,%.2f;%d / %d]", y + 0.55, state.progress, state.goal)
  end
  parts[#parts + 1] = "button[0.8,8.35;3,0.7;back;QUESTS]"
  parts[#parts + 1] = "button_exit[7.2,8.35;3,0.7;close;CLOSE]"
  core.show_formspec(player:get_player_name(), "nv_rpg:endless", table.concat(parts))
end
core.register_on_player_receive_fields(function(player, formname, fields)
  if not player or not player:is_player() then return end
  if formname == "nv_rpg:quests" and fields.endless then show_endless(player)
  elseif formname == "nv_rpg:endless" and fields.back then show(player) end
end)
novaterra_rpg.show_endless = show_endless
novaterra_rpg.show = show

core.register_chatcommand("nvquests", {
  description="Open NOVATERRA quest journal",
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false,"Player not connected" end
    show(player)
    return true
  end,
})
core.register_on_joinplayer(function(player)
  if player:get_meta():get_int("nv_quest_intro") == 0 then
    player:get_meta():set_int("nv_quest_intro",1)
    notify(player,"New quest journal unlocked. Type /nvquests to view goals.")
  end
end)
