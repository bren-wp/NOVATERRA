-- Basic stone furnace, with persistent node inventory and timer.
local function furnace_formspec()
  return "formspec_version[4]size[8.5,8]label[0.5,0.5;NOVATERRA FURNACE]"..
    "label[0.5,1.3;ORE]list[context;src;0.5,1.7;1,1;]"..
    "label[2.5,1.3;FUEL]list[context;fuel;2.5,1.7;1,1;]"..
    "label[5.5,1.3;OUTPUT]list[context;dst;5.5,1.7;1,1;]"..
    "list[current_player;main;0.3,3.2;8,4;]"..
    "listring[context;src]listring[current_player;main]"..
    "listring[context;fuel]listring[current_player;main]"
end
local function on_timer(pos)
  local meta=core.get_meta(pos)
  local inv=meta:get_inventory()
  local src=inv:get_stack("src",1)
  if src:is_empty() then return false end
  local cooked=core.get_craft_result({method="cooking",width=1,items={src}})
  if not cooked or not cooked.item or cooked.item:is_empty() then return false end
  if not inv:room_for_item("dst",cooked.item) then return false end
  local remaining=meta:get_int("fuel_remaining")
  if remaining<=0 then
    local fuel=inv:get_stack("fuel",1)
    if fuel:is_empty() then return false end
    local result,after=core.get_craft_result({method="fuel",width=1,items={fuel}})
    if not result or (result.time or 0)<=0 then return false end
    local replacement=after and after.items and after.items[1]
    if replacement then inv:set_stack("fuel",1,replacement)
    else fuel:take_item(1);inv:set_stack("fuel",1,fuel) end
    remaining=math.max(1,math.floor(result.time))
  end
  remaining=remaining-1
  meta:set_int("fuel_remaining",remaining)
  local progress=meta:get_int("progress")+1
  if progress>=math.max(1,math.ceil(cooked.time or 8)) then
    src:take_item(1);inv:set_stack("src",1,src)
    inv:add_item("dst",cooked.item)
    progress=0
  end
  meta:set_int("progress",progress)
  return true
end
core.register_node("nv_world:furnace",{
  description="Stone Furnace",tiles={"nv_cobble.png"},groups={cracky=2},
  on_construct=function(pos)
    local meta=core.get_meta(pos)
    local inv=meta:get_inventory()
    inv:set_size("src",1);inv:set_size("fuel",1);inv:set_size("dst",1)
    meta:set_string("formspec",furnace_formspec())
  end,
  on_timer=on_timer,
  on_metadata_inventory_put=function(pos) core.get_node_timer(pos):start(1) end,
  on_metadata_inventory_take=function(pos) core.get_node_timer(pos):start(1) end,
  allow_metadata_inventory_put=function(pos,listname,index,stack,player)
    if listname=="dst" or not player or core.is_protected(pos,player:get_player_name()) then return 0 end
    return stack:get_count()
  end,
  allow_metadata_inventory_take=function(pos,listname,index,stack,player)
    if not player or core.is_protected(pos,player:get_player_name()) then return 0 end
    return stack:get_count()
  end,
  can_dig=function(pos,player)
    if not player or core.is_protected(pos,player:get_player_name()) then return false end
    local inv=core.get_meta(pos):get_inventory()
    return inv:is_empty("src") and inv:is_empty("fuel") and inv:is_empty("dst")
  end,
})
core.register_craft({output="nv_world:furnace",recipe={
  {"nv_core:cobble","nv_core:cobble","nv_core:cobble"},
  {"nv_core:cobble","","nv_core:cobble"},
  {"nv_core:cobble","nv_core:cobble","nv_core:cobble"},
}})
core.register_craftitem("nv_world:iron_ingot",{description="Iron Ingot",inventory_image="nv_iron_overlay.png"})
core.register_craft({type="cooking",output="nv_world:iron_ingot",recipe="nv_world:raw_iron",cooktime=8})
core.register_craft({type="fuel",recipe="nv_world:coal",burntime=40})
core.register_craft({type="fuel",recipe="nv_core:wood",burntime=8})
core.register_lbm({label="Restart furnaces",name="nv_world:restart_furnaces",
  nodenames={"nv_world:furnace"},run_at_every_load=true,
  action=function(pos)
    if not core.get_meta(pos):get_inventory():is_empty("src") then
      core.get_node_timer(pos):start(1)
    end
  end,
})
