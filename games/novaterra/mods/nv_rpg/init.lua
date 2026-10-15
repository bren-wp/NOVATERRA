-- NOVATERRA RPG journal: persistent, server-authoritative challenges and XP.
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
  return math.floor(experience(player) / 150) + 1
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
  if previous >= def.goal then return false end
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
  parts[#parts + 1] = "button_exit[4.2,8.45;2.6,0.65;close;BACK TO GAME]"
  core.show_formspec(name, "nv_rpg:quests", table.concat(parts))
end
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
