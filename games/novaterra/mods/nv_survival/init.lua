-- NOVATERRA survival: persistent hunger, food and HUD.
novaterra_survival = {}
local cache = {}
local function get_state(player)
  local name = player:get_player_name()
  if cache[name] then return cache[name] end
  local meta = player:get_meta()
  local hunger = tonumber(meta:get_string("nv_hunger")) or 20
  local state = {
    hunger = math.max(0,math.min(20,hunger)),
    visible = meta:get_string("nv_hud") ~= "false",
    coordinates_visible = meta:get_string("nv_coordinates") == "true",
  }
  cache[name] = state
  return state
end
local function refresh(player)
  local s = get_state(player)
  local hp = math.max(0,math.floor(player:get_hp()))
  local props = player:get_properties() or {}
  local max_hp = props.hp_max or 20
  local status = string.format("HP %d/%d   |   FOOD %d/20",hp,max_hp,s.hunger)
  if s.visible then
    if not s.health_id then
      s.health_id = player:hud_add({
        hud_elem_type="text",position={x=0.5,y=0.025},
        offset={x=0,y=0},alignment={x=0,y=0},
        text=status,number=0xFFFFFF,scale={x=100,y=24},
      })
    else
      player:hud_change(s.health_id,"text",status)
    end
  elseif s.health_id then
    player:hud_remove(s.health_id);s.health_id=nil
  end
  if s.coordinates_visible then
    local p = player:get_pos()
    local coordinates = string.format("X %d  Y %d  Z %d",math.floor(p.x),math.floor(p.y),math.floor(p.z))
    if not s.coord_id then
      s.coord_id = player:hud_add({
        hud_elem_type="text",position={x=0.99,y=0.045},
        offset={x=-12,y=0},alignment={x=-1,y=0},
        text=coordinates,number=0xFFFFFF,
      })
    else
      player:hud_change(s.coord_id,"text",coordinates)
    end
  elseif s.coord_id then
    player:hud_remove(s.coord_id);s.coord_id=nil
  end
end
function novaterra_survival.set_hud_visible(player,enabled)
  local s=get_state(player)
  s.visible=not not enabled
  player:get_meta():set_string("nv_hud",tostring(s.visible))
  refresh(player)
end
function novaterra_survival.set_coordinates_visible(player,enabled)
  local s=get_state(player)
  s.coordinates_visible=not not enabled
  player:get_meta():set_string("nv_coordinates",tostring(s.coordinates_visible))
  refresh(player)
end
function novaterra_survival.get_hunger(player)
  return get_state(player).hunger
end
function novaterra_survival.feed(player,amount)
  local s=get_state(player)
  s.hunger=math.max(0,math.min(20,s.hunger+amount))
  player:get_meta():set_string("nv_hunger",tostring(s.hunger))
  refresh(player)
end
core.register_craftitem("nv_survival:apple",{
  description="Apple",inventory_image="nv_apple.png",
  on_use=function(itemstack,user)
    if user and user:is_player() then
      novaterra_survival.feed(user,4)
      itemstack:take_item(1)
    end
    return itemstack
  end,
})
core.register_on_joinplayer(function(player)
  get_state(player)
  refresh(player)
end)
core.register_on_leaveplayer(function(player)
  cache[player:get_player_name()]=nil
end)
core.register_on_respawnplayer(function(player)
  local s=get_state(player)
  s.hunger=20
  player:get_meta():set_string("nv_hunger","20")
  refresh(player)
end)
local hud_clock=0
local hunger_clock=0
core.register_globalstep(function(dt)
  hud_clock=hud_clock+dt
  hunger_clock=hunger_clock+dt
  if hud_clock>=1 then
    hud_clock=0
    for _,player in ipairs(core.get_connected_players()) do refresh(player) end
  end
  if hunger_clock>=60 then
    hunger_clock=0
    for _,player in ipairs(core.get_connected_players()) do
      local s=get_state(player)
      if player:get_hp()>0 then
        s.hunger=math.max(0,s.hunger-1)
        player:get_meta():set_string("nv_hunger",tostring(s.hunger))
        if s.hunger==0 then player:set_hp(math.max(0,player:get_hp()-1)) end
        refresh(player)
      end
    end
  end
end)
