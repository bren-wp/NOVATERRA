-- NOVATERRA survival module. Hunger is authoritative on the server.
local state = {}
local MAX_HUNGER = 20
local TICK_SECONDS = 30
local HUNGER_TICKS = 4 -- one hunger point every two minutes
local function clamp(value)
  return math.max(0, math.min(MAX_HUNGER, math.floor(value)))
end
local function update_hud(player, data)
  if not player or not player:is_player() then return end
  local hearts = math.ceil(player:get_hp() / 2)
  local hunger = math.ceil(data.hunger / 2)
  local max_hp = (player:get_properties() or {}).hp_max or 20
  if data.hud_visible == false then return end
  player:hud_change(data.hud_health, 'text', 'HP  ' .. string.rep('♥', math.max(0, hearts)) .. '  ' .. player:get_hp() .. '/' .. max_hp)
  player:hud_change(data.hud_hunger, 'text', 'FOOD  ' .. string.rep('●', math.max(0, hunger)) .. '  ' .. data.hunger .. '/20')
  if data.hud_coordinates then
    local pos = player:get_pos()
    if pos then player:hud_change(data.hud_coordinates, 'text', string.format('X %.0f   Y %.0f   Z %.0f', pos.x, pos.y, pos.z)) end
  end
end
local function save(player, data)
  player:get_meta():set_int('nv_hunger', data.hunger)
  player:get_meta():set_int('nv_hunger_initialized', 1)
end
-- Shared hunger API for food items supplied by other gameplay modules.
novaterra_survival = novaterra_survival or {}
function novaterra_survival.feed(player, amount)
  if not player or not player:is_player() then return false end
  local data = state[player:get_player_name()]
  if not data or data.hunger >= MAX_HUNGER then return false end
  if type(amount) ~= 'number' or amount <= 0 or amount > MAX_HUNGER then return false end
  data.hunger = clamp(data.hunger + amount)
  save(player, data)
  update_hud(player, data)
  return true
end
local function consume_food(itemstack, user)
  if not user or not user:is_player() then return itemstack end
  local data = state[user:get_player_name()]
  if not data or data.hunger >= MAX_HUNGER then return itemstack end
  data.hunger = clamp(data.hunger + 6)
  save(user, data)
  update_hud(user, data)
  itemstack:take_item(1)
  return itemstack
end
core.register_craftitem('nv_survival:trail_ration', {
  description = 'Trail Ration (+6 hunger)',
  inventory_image = 'nv_wood.png^[colorize:#d59c48:145',
  on_use = consume_food,
})
core.register_craft({output='nv_survival:trail_ration 2', recipe={{'nv_core:leaves','nv_core:leaves'},{'nv_core:wood','nv_core:wood'}}})
core.register_on_joinplayer(function(player)
  local meta = player:get_meta()
  local hunger = meta:get_int('nv_hunger_initialized') == 1 and meta:get_int('nv_hunger') or MAX_HUNGER
  local data = {hunger=clamp(hunger), elapsed=0, ticks=0, hud_visible=meta:get_int('nv_hide_hud') ~= 1, coordinates_visible=meta:get_int('nv_show_coordinates') == 1}
  data.hud_health = player:hud_add({hud_elem_type='text', position={x=0.02,y=0.04}, offset={x=0,y=0}, text='', number=0xF66B65, alignment={x=1,y=0}, scale={x=100,y=20}})
  data.hud_hunger = player:hud_add({hud_elem_type='text', position={x=0.02,y=0.085}, offset={x=0,y=0}, text='', number=0xF0C16A, alignment={x=1,y=0}, scale={x=100,y=20}})
  data.hud_coordinates = player:hud_add({hud_elem_type='text', position={x=0.98,y=0.04}, offset={x=0,y=0}, text='', number=0xE7DBBD, alignment={x=-1,y=0}, scale={x=100,y=20}})
  state[player:get_player_name()] = data
  save(player, data)
  update_hud(player, data)
  if not data.coordinates_visible then player:hud_change(data.hud_coordinates, 'text', '') end
  if not data.hud_visible then
    player:hud_change(data.hud_health, 'text', '')
    player:hud_change(data.hud_hunger, 'text', '')
  end
end)
core.register_on_leaveplayer(function(player)
  local name = player:get_player_name()
  local data = state[name]
  if data then save(player, data) end
  state[name] = nil
end)
core.register_on_dieplayer(function(player)
  local data = state[player:get_player_name()]
  if data then data.hunger = MAX_HUNGER; data.ticks=0; save(player,data) end
end)
core.register_globalstep(function(dtime)
  for _, player in ipairs(core.get_connected_players()) do
    local data = state[player:get_player_name()]
    if data then
      data.elapsed = data.elapsed + dtime
      if data.elapsed >= TICK_SECONDS then
        local ticks = math.floor(data.elapsed / TICK_SECONDS)
        data.elapsed = data.elapsed - ticks * TICK_SECONDS
        data.ticks = data.ticks + ticks
        if data.ticks >= HUNGER_TICKS then
          local loss = math.floor(data.ticks / HUNGER_TICKS)
          data.ticks = data.ticks % HUNGER_TICKS
          data.hunger = clamp(data.hunger - loss)
          save(player, data)
        end
        if data.hunger == 0 and player:get_hp() > 1 then
          player:set_hp(player:get_hp() - 1, {type='set_hp',from='mod'})
        end
        update_hud(player, data)
        if data.coordinates_visible then
          local pos = player:get_pos()
          if pos then player:hud_change(data.hud_coordinates, 'text', string.format('X %.0f   Y %.0f   Z %.0f', pos.x, pos.y, pos.z)) end
        end
      end
    end
  end
end)

-- Shared server-side HUD visibility API for the settings form.
novaterra_survival = novaterra_survival or {}
function novaterra_survival.set_hud_visible(player, visible)
  if not player or not player:is_player() then return false end
  local data = state[player:get_player_name()]
  if not data then return false end
  data.hud_visible = visible == true
  player:get_meta():set_int('nv_hide_hud', data.hud_visible and 0 or 1)
  if data.hud_visible then
    update_hud(player, data)
  else
    player:hud_change(data.hud_health, 'text', '')
    player:hud_change(data.hud_hunger, 'text', '')
  end
  return true
end
core.register_on_respawnplayer(function(player)
  local data = state[player:get_player_name()]
  if data then
    data.hunger = MAX_HUNGER
    data.ticks = 0
    save(player, data)
    update_hud(player, data)
  end
end)
-- Accessibility: players can hide/show the text overlay independently.
core.register_chatcommand('nvhud', {
  description = 'Toggle NOVATERRA survival HUD',
  func = function(name)
    local player = core.get_player_by_name(name)
    local data = state[name]
    if not player or not data then return false, 'Player not connected' end
    novaterra_survival.set_hud_visible(player, not data.hud_visible)
    return true, data.hud_visible and 'NOVATERRA HUD enabled' or 'NOVATERRA HUD hidden'
  end,
})

-- Optional location readout is independent of the survival overlay.
function novaterra_survival.set_coordinates_visible(player, visible)
  if not player or not player:is_player() then return false end
  local data = state[player:get_player_name()]
  if not data then return false end
  data.coordinates_visible = visible == true
  player:get_meta():set_int('nv_show_coordinates', data.coordinates_visible and 1 or 0)
  if data.coordinates_visible then
    local pos = player:get_pos()
    if pos then player:hud_change(data.hud_coordinates, 'text', string.format('X %.0f   Y %.0f   Z %.0f', pos.x, pos.y, pos.z)) end
  else
    player:hud_change(data.hud_coordinates, 'text', '')
  end
  return true
end
