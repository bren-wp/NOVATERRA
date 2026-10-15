local function node(name, description, texture, groups, extra)
  local def = {description=description, tiles={texture}, groups=groups or {cracky=3}, is_ground_content=true}
  if extra then for k,v in pairs(extra) do def[k]=v end end
  core.register_node('nv_core:'..name, def)
end
node('stone','Stone','nv_stone.png',{cracky=3,stone=1},{drop='nv_core:cobble'})
node('cobble','Cobblestone','nv_cobble.png',{cracky=3,stone=1})
node('dirt','Dirt','nv_dirt.png',{crumbly=3,soil=1})
node('grass','Grass','nv_grass_top.png',{crumbly=3,soil=1}, {tiles={'nv_grass_top.png','nv_dirt.png','nv_grass_side.png'}})
node('sand','Sand','nv_sand.png',{crumbly=3,falling_node=1})
node('wood','Oak Planks','nv_wood.png',{choppy=2,flammable=2,wood=1})
node('tree','Oak Log','nv_tree_top.png',{choppy=2,tree=1,flammable=2}, {tiles={'nv_tree_top.png','nv_tree_top.png','nv_tree_side.png'}})
node('leaves','Oak Leaves','nv_leaves.png',{snappy=3,leafdecay=3,leaves=1,flammable=2}, {drawtype='allfaces_optional', paramtype='light', sunlight_propagates=true, waving=1})
node('glass','Glass','nv_glass.png',{cracky=3}, {drawtype='glasslike', paramtype='light', sunlight_propagates=true, use_texture_alpha='blend'})
node('torch','Torch','nv_torch.png',{dig_immediate=3,attached_node=1}, {drawtype='torchlike', paramtype='light', sunlight_propagates=true, light_source=12, walkable=false, selection_box={type='wallmounted'}, paramtype2='wallmounted'})
core.register_node('nv_core:water_source', {description='Water', drawtype='liquid', tiles={'nv_water.png'}, special_tiles={{name='nv_water.png',backface_culling=false}}, paramtype='light', walkable=false, pointable=false, diggable=false, buildable_to=true, liquidtype='source', liquid_alternative_flowing='nv_core:water_flowing', liquid_alternative_source='nv_core:water_source', liquid_viscosity=1, groups={water=3,liquid=3}, is_ground_content=false})
core.register_node('nv_core:water_flowing', {description='Flowing Water', drawtype='flowingliquid', tiles={'nv_water.png'}, special_tiles={{name='nv_water.png',backface_culling=false},{name='nv_water.png',backface_culling=true}}, paramtype='light', paramtype2='flowingliquid', walkable=false, pointable=false, diggable=false, buildable_to=true, liquidtype='flowing', liquid_alternative_flowing='nv_core:water_flowing', liquid_alternative_source='nv_core:water_source', liquid_viscosity=1, groups={water=3,liquid=3}, is_ground_content=false})
local aliases={stone='stone',dirt='dirt',dirt_with_grass='grass',sand='sand',water_source='water_source',river_water_source='water_source',lava_source='stone',gravel='cobble',desert_sand='sand',desert_stone='stone',sandstone='stone',snow='grass',snowblock='stone',ice='glass',dirt_with_snow='grass',stair_sandstonebrick='stone',stair_desert_stone='stone',mossycobble='cobble',cobble='cobble',stair_cobble='cobble',stair_stone='stone',stair_sandstone='stone',sandstonebrick='stone',desert_sandstone='stone',desert_sandstone_brick='stone',silver_sand='sand',stair_desert_sandstone_brick='stone',stair_desert_sandstone='stone',stair_sandstone_block='stone',stair_desert_sandstone_block='stone',stair_silver_sandstone='stone',silver_sandstone='stone',silver_sandstone_brick='stone',stair_silver_sandstone_brick='stone',stair_silver_sandstone_block='stone',silver_sandstone_block='stone',stair_stone_block='stone',stone_block='stone',stair_stonebrick='stone',stonebrick='stone',stair_desert_stone_block='stone',desert_stone_block='stone',stair_desert_stonebrick='stone',desert_stonebrick='stone'}
for source,target in pairs(aliases) do core.register_alias('mapgen_'..source,'nv_core:'..target) end
core.register_tool('nv_core:pickaxe', {description='Stone Pickaxe', inventory_image='nv_pickaxe.png', tool_capabilities={full_punch_interval=1.2,max_drop_level=0,groupcaps={cracky={times={[1]=7,[2]=3,[3]=1},uses=35,maxlevel=1}},damage_groups={fleshy=2}}})
core.register_tool('nv_core:axe', {description='Wooden Axe', inventory_image='nv_axe.png', tool_capabilities={full_punch_interval=1.2,max_drop_level=0,groupcaps={choppy={times={[1]=4,[2]=2,[3]=1},uses=30,maxlevel=1}},damage_groups={fleshy=2}}})
core.register_craft({output='nv_core:wood 4',recipe={{'nv_core:tree'}}})
core.register_craft({output='nv_core:pickaxe',recipe={{'nv_core:cobble','nv_core:cobble','nv_core:cobble'},{'','nv_core:wood',''},{'','nv_core:wood',''}}})
core.register_craft({output='nv_core:axe',recipe={{'nv_core:wood','nv_core:wood'},{'nv_core:wood','nv_core:wood'},{'','nv_core:wood'}}})
core.register_craft({type='cooking', output='nv_core:glass', recipe='nv_core:sand', cooktime=8})
local function inventory_formspec()
  return table.concat({
    'formspec_version[4]size[12.6,10.2]','bgcolor[#09161DEB;true]',
    'label[0.6,0.35;NOVATERRA  |  INVENTORY & CRAFTING]',
    'box[0.55,0.95;4.0,4.05;#14252FCC]','label[0.85,1.12;CRAFTING]',
    'list[current_player;craft;0.9,1.55;3,3;]','label[4.72,2.5;>]',
    'list[current_player;craftpreview;5.3,2.15;1,1;]',
    'label[0.65,5.18;BACKPACK]','list[current_player;main;0.65,5.6;8,4;]',
    'button[9.3,5.6;2.55,0.85;nv_guide;SURVIVAL GUIDE]',
    'label[9.3,6.8;BUILD  /  EXPLORE]','label[9.3,7.3;SURVIVE  /  THRIVE]',
    'listring[current_player;main]','listring[current_player;craft]',
  })
end
core.register_on_joinplayer(function(player)
  local inv=player:get_inventory()
  inv:set_size('main',32)
  inv:set_size('craft',9)
  player:set_inventory_formspec(inventory_formspec())
  local meta=player:get_meta()
  if meta:get_int('nv_starter') == 0 then
    inv:add_item('main','nv_core:wood 20')
    inv:add_item('main','nv_core:tree 12')
    inv:add_item('main','nv_core:pickaxe')
    inv:add_item('main','nv_core:axe')
    inv:add_item('main','nv_core:torch 16')
    meta:set_int('nv_starter',1)
    core.chat_send_player(player:get_player_name(),'Welcome to NOVATERRA! Explore, mine and build.')
  end
end)
core.register_decoration({
  deco_type='schematic',place_on={'nv_core:grass'},sidelen=16,fill_ratio=0.007,
  y_min=1,y_max=120,
  schematic={
    size={x=5,y=6,z=5},
    data=(function()
      local data={}
      for y=1,6 do for z=1,5 do for x=1,5 do
        local trunk=x==3 and z==3 and y<=5
        local crown=y>=4 and y<=6 and math.abs(x-3)+math.abs(z-3)<=3
        data[#data+1]={name=trunk and 'nv_core:tree' or (crown and 'nv_core:leaves' or 'air'),prob=trunk and 255 or (crown and 225 or 0)}
      end end end
      return data
    end)(),
  },
  flags='place_center_x,place_center_z',rotation='random',
})
