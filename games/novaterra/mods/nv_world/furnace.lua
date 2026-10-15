-- NOVATERRA furnace: server-authoritative inventory and timed cooking.
local function spec()
  return table.concat({
    'formspec_version[4]size[9,8]',
    'bgcolor[#101C22;true]',
    'box[0.2,0.2;8.6,7.6;#182C34]',
    'label[0.6,0.7;NOVATERRA / FURNACE]',
    'label[0.8,1.4;INPUT]', 'list[context;src;0.8,1.8;1,1;]',
    'label[3.1,1.4;FUEL]', 'list[context;fuel;3.1,1.8;1,1;]',
    'label[6.1,1.4;OUTPUT]', 'list[context;dst;6.1,1.8;1,1;]',
    'list[current_player;main;0.5,3.3;8,4;]',
    'listring[context;src]', 'listring[current_player;main]',
    'listring[context;fuel]', 'listring[current_player;main]',
    'listring[context;dst]', 'listring[current_player;main]',
  })
end
local function tick(pos)
  local meta = core.get_meta(pos)
  local inv = meta:get_inventory()
  local src = inv:get_stack('src', 1)
  local fuel = inv:get_stack('fuel', 1)
  if src:is_empty() then meta:set_int('progress', 0); return false end
  local recipe = core.get_craft_result({method='cooking', width=1, items={src}})
  local result = recipe and recipe.item
  if not result or result:is_empty() or not inv:room_for_item('dst', result) then
    meta:set_int('progress', 0); return false
  end
  local progress = meta:get_int('progress')
  local remaining = meta:get_int('fuel_remaining')
  if remaining <= 0 then
    if fuel:is_empty() then return false end
    local burn, replacements = core.get_craft_result({method='fuel', width=1, items={fuel}})
    if not burn or (burn.time or 0) <= 0 then return false end
    -- Respect replacement containers returned by the engine (e.g. lava bucket).
    local leftover = replacements and replacements.items and replacements.items[1]
    if leftover then
      inv:set_stack('fuel', 1, leftover)
    else
      fuel:take_item(1)
      inv:set_stack('fuel', 1, fuel)
    end
    remaining = math.max(1, math.floor(burn.time))
  end
  remaining = remaining - 1
  progress = progress + 1
  local cooktime = math.max(1, math.ceil(recipe.time or 8))
  if progress >= cooktime then
    src:take_item(1)
    inv:set_stack('src', 1, src)
    inv:add_item('dst', result) -- room_for_item checked above
    progress = 0
  end
  meta:set_int('progress', progress)
  meta:set_int('fuel_remaining', remaining)
  meta:set_string('infotext', 'Stone Furnace - cooking ' .. tostring(math.floor(100 * progress / cooktime)) .. '%')
  return true
end
core.register_node('nv_world:furnace', {
  description='Stone Furnace', tiles={'nv_cobble.png'},
  groups={cracky=2},
  on_construct=function(pos)
    local meta=core.get_meta(pos)
    local inv=meta:get_inventory()
    inv:set_size('src',1); inv:set_size('fuel',1); inv:set_size('dst',1)
    meta:set_string('formspec',spec())
    meta:set_string('infotext', 'Stone Furnace')
  end,
  on_timer=function(pos)
    local active=tick(pos)
    if not active then return false end
    return true
  end,
  on_metadata_inventory_put=function(pos)
    core.get_node_timer(pos):start(1)
  end,
  on_metadata_inventory_take=function(pos)
    core.get_node_timer(pos):start(1)
  end,
  on_metadata_inventory_move=function(pos)
    core.get_node_timer(pos):start(1)
  end,
  allow_metadata_inventory_put=function(pos,listname,index,stack,player)
    if listname=='dst' or not player or not player:is_player() then return 0 end
    if core.is_protected(pos,player:get_player_name()) then return 0 end
    return stack:get_count()
  end,
  allow_metadata_inventory_take=function(pos,listname,index,stack,player)
    if not player or not player:is_player() then return 0 end
    if core.is_protected(pos,player:get_player_name()) then return 0 end
    return stack:get_count()
  end,
  allow_metadata_inventory_move=function() return 0 end,
  can_dig=function(pos,player)
    if not player or core.is_protected(pos,player:get_player_name()) then return false end
    local inv=core.get_meta(pos):get_inventory()
    return inv:is_empty('src') and inv:is_empty('fuel') and inv:is_empty('dst')
  end,
})
core.register_craft({output='nv_world:furnace',recipe={
  {'nv_core:cobble','nv_core:cobble','nv_core:cobble'},
  {'nv_core:cobble','','nv_core:cobble'},
  {'nv_core:cobble','nv_core:cobble','nv_core:cobble'},
}})
core.register_craftitem('nv_world:iron_ingot', {description='Iron Ingot', inventory_image='nv_iron_overlay.png'})
core.register_craft({type='cooking',output='nv_world:iron_ingot',recipe='nv_world:raw_iron',cooktime=8})
core.register_craft({type='fuel',recipe='nv_world:coal',burntime=40})
core.register_craft({type='fuel',recipe='nv_core:wood',burntime=8})

-- Restart interrupted cooking after a server restart or world reload.
core.register_lbm({
  label='Resume NOVATERRA furnaces',
  name='nv_world:resume_furnace',
  nodenames={'nv_world:furnace'},
  run_at_every_load=true,
  action=function(pos)
    local inv=core.get_meta(pos):get_inventory()
    if not inv:is_empty('src') then
      core.get_node_timer(pos):start(1)
    end
  end,
})
