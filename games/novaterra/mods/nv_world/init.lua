-- World content registered before map generation; affects newly generated terrain.
local function biome(name, surface, depth, heat, humidity, y_min, y_max)
  core.register_biome({
    name = 'novaterra_' .. name,
    node_top = surface, depth_top = 1,
    node_filler = depth, depth_filler = 3,
    node_stone = 'nv_core:stone',
    node_water_top = 'nv_core:water_source', depth_water_top = 1,
    node_water = 'nv_core:water_source',
    y_min = y_min or -31000, y_max = y_max or 31000,
    heat_point = heat, humidity_point = humidity,
  })
end
biome('meadow', 'nv_core:grass', 'nv_core:dirt', 55, 65)
biome('woodland', 'nv_core:grass', 'nv_core:dirt', 48, 85)
biome('drylands', 'nv_core:sand', 'nv_core:sand', 88, 12)
biome('highlands', 'nv_core:stone', 'nv_core:stone', 24, 40, 45, 31000)
biome('shore', 'nv_core:sand', 'nv_core:sand', 70, 55, -5, 4)

-- Ore deposits use Luanti's engine mapgen and are limited to stone.
core.register_ore({
  ore_type = 'scatter', ore = 'nv_world:coal_ore', wherein = 'nv_core:stone',
  clust_scarcity = 9 * 9 * 9, clust_num_ores = 6, clust_size = 3,
  y_min = -31000, y_max = 80,
})
core.register_ore({
  ore_type = 'scatter', ore = 'nv_world:iron_ore', wherein = 'nv_core:stone',
  clust_scarcity = 12 * 12 * 12, clust_num_ores = 4, clust_size = 3,
  y_min = -31000, y_max = 24,
})
core.register_node('nv_world:coal_ore', {
  description = 'Coal Ore', tiles = {'nv_stone.png^nv_coal_overlay.png'},
  groups = {cracky=3, stone=1}, drop = 'nv_world:coal',
})
core.register_node('nv_world:iron_ore', {
  description = 'Iron Ore', tiles = {'nv_stone.png^nv_iron_overlay.png'},
  groups = {cracky=2, stone=1}, drop = 'nv_world:raw_iron',
})
core.register_craftitem('nv_world:coal', {
  description = 'Coal', inventory_image = 'nv_coal_overlay.png',
})
core.register_craftitem('nv_world:raw_iron', {
  description = 'Raw Iron', inventory_image = 'nv_iron_overlay.png',
})
core.register_craft({output='nv_core:torch 4', recipe={{'nv_world:coal'},{'nv_core:wood'}}})

-- Small ground vegetation uses engine decorations rather than expensive callbacks.
core.register_node('nv_world:tall_grass', {
  description='Tall Grass', drawtype='plantlike', waving=1,
  tiles={'nv_grass_top.png'}, inventory_image='nv_grass_top.png',
  wield_image='nv_grass_top.png', paramtype='light', sunlight_propagates=true,
  walkable=false, buildable_to=true, groups={snappy=3, flora=1, attached_node=1},
  selection_box={type='fixed', fixed={-0.25,-0.5,-0.25,0.25,0.25,0.25}},
})
core.register_decoration({
  deco_type='simple', place_on={'nv_core:grass'}, sidelen=16,
  fill_ratio=0.08, y_min=1, y_max=120,
  decoration='nv_world:tall_grass',
})

-- Smelting station
dofile(core.get_modpath("nv_world") .. "/furnace.lua")

-- In-game map and persistent waypoint controls.
dofile(core.get_modpath('nv_world') .. '/map.lua')
