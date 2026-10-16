-- NOVATERRA 0.0.3: original, deterministic, engine-native landscape palette.
-- Extends mapgen v7 without changing existing biome names or saved-world data.
-- Tinted textures reuse NOVATERRA's own PNGs; no network-loaded assets.
local function terrain(name, description, texture, color, groups, extra)
  local def = {
    description = description,
    tiles = {texture .. "^[colorize:" .. color},
    groups = groups or {crumbly = 3, soil = 1},
    is_ground_content = true,
  }
  if extra then for key, value in pairs(extra) do def[key] = value end end
  core.register_node("nv_world:" .. name, def)
end

local soil = {crumbly = 3, soil = 1}
local rock = {cracky = 3, stone = 1}
terrain("snowcap", "Alpine Snow", "nv_stone.png", "#EDF6FA:223", rock)
terrain("frostgrass", "Frost Meadow", "nv_grass_top.png", "#C8E3DB:138", soil)
terrain("ice", "Glacial Ice", "nv_glass.png", "#98D8F1:193", rock, {
  drawtype = "glasslike", paramtype = "light",
  sunlight_propagates = true, use_texture_alpha = "blend",
})
terrain("frozen_dirt", "Permafrost", "nv_dirt.png", "#B3C3CD:130", soil)
terrain("mud", "Marsh Mud", "nv_dirt.png", "#3D4938:155", soil)
terrain("lush_grass", "Rainforest Floor", "nv_grass_top.png", "#248E49:112", soil)
terrain("dry_grass", "Savanna Grass", "nv_grass_top.png", "#D6BB66:167", soil)
terrain("red_sand", "Badlands Red Sand", "nv_sand.png", "#C45238:170", {crumbly=3, falling_node=1})
terrain("ochre_stone", "Canyon Sandstone", "nv_stone.png", "#D68B54:172", rock)
terrain("basalt", "Volcanic Basalt", "nv_stone.png", "#22212C:202", rock)
terrain("violet_grass", "Twilight Grass", "nv_grass_top.png", "#6249A8:154", soil)
terrain("blossom_grass", "Blossom Meadow", "nv_grass_top.png", "#E7A8BA:122", soil)
terrain("crystal_stone", "Prismatic Stone", "nv_stone.png", "#4CBBC1:137", rock)
terrain("deep_silt", "Ocean Floor Silt", "nv_dirt.png", "#355A6B:171", soil)
terrain("ancient_grass", "Ancient Woodland", "nv_grass_top.png", "#355F44:152", soil)

local function biome(name, top, filler, heat, humidity, low, high)
  core.register_biome({
    name = "novaterra_" .. name,
    node_top = "nv_world:" .. top,
    depth_top = 1,
    node_filler = filler:find(":") and filler or ("nv_world:" .. filler),
    depth_filler = 3,
    node_stone = "nv_core:stone",
    node_water_top = "nv_core:water_source",
    depth_water_top = 1,
    node_water = "nv_core:water_source",
    y_min = low, y_max = high,
    heat_point = heat, humidity_point = humidity,
  })
end

-- Fifteen additional climates augment the five original biomes. Their unique
-- surface materials and altitude ranges create distinct landscapes in new land.
biome("alpine", "snowcap", "nv_core:stone", 12, 45, 96, 31000)
biome("frostwood", "frostgrass", "frozen_dirt", 20, 73, 15, 160)
biome("glacier", "ice", "snowcap", 5, 30, 72, 31000)
biome("tundra", "frostgrass", "frozen_dirt", 17, 20, 4, 120)
biome("marsh", "mud", "mud", 52, 96, -5, 30)
biome("rainforest", "lush_grass", "nv_core:dirt", 86, 91, 2, 220)
biome("savanna", "dry_grass", "nv_core:dirt", 82, 37, 3, 180)
biome("badlands", "red_sand", "red_sand", 90, 7, 3, 180)
biome("canyon", "ochre_stone", "ochre_stone", 78, 12, 25, 220)
biome("volcanic", "basalt", "basalt", 96, 32, 65, 350)
biome("twilight_grove", "violet_grass", "nv_core:dirt", 43, 80, 3, 180)
biome("blossom_fields", "blossom_grass", "nv_core:dirt", 61, 69, 3, 160)
biome("crystal_valley", "crystal_stone", "nv_core:stone", 30, 34, 35, 230)
biome("ocean_depths", "deep_silt", "deep_silt", 65, 80, -31000, -8)
biome("redwood", "ancient_grass", "nv_core:dirt", 48, 91, 3, 220)

local function flora(name, description, texture, color, glow)
  local image = texture .. "^[colorize:" .. color
  core.register_node("nv_world:" .. name, {
    description = description, drawtype = "plantlike", waving = 1,
    tiles = {image}, inventory_image = image, wield_image = image,
    paramtype = "light", sunlight_propagates = true, walkable = false,
    buildable_to = true, light_source = glow or 0,
    selection_box = {type = "fixed", fixed = {-0.25,-0.5,-0.25,0.25,0.25,0.25}},
    groups = {snappy=3, flora=1, attached_node=1},
  })
end
flora("wildflower", "Golden Wildflower", "nv_grass_top.png", "#F8CF61:215")
flora("reed", "Marsh Reed", "nv_tree_side.png", "#7B9E58:182")
flora("emberbloom", "Emberbloom", "nv_torch.png", "#E56735:155", 3)
flora("crystal_sprout", "Crystal Sprout", "nv_glass.png", "#A16BF3:192", 3)
flora("dry_shrub", "Dryland Shrub", "nv_leaves.png", "#A78B52:193")

local function flowers(name, places, frequency, low, high)
  core.register_decoration({
    deco_type = "simple", place_on = places,
    sidelen = 16, fill_ratio = frequency,
    y_min = low, y_max = high,
    decoration = "nv_world:" .. name,
  })
end
flowers("wildflower", {"nv_core:grass", "nv_world:blossom_grass"}, 0.07, 3, 160)
flowers("reed", {"nv_world:mud"}, 0.12, 0, 28)
flowers("emberbloom", {"nv_world:basalt"}, 0.035, 65, 350)
flowers("crystal_sprout", {"nv_world:crystal_stone"}, 0.065, 35, 230)
flowers("dry_shrub", {"nv_world:dry_grass", "nv_world:red_sand"}, 0.04, 3, 180)

-- Sparse, original stone ruins. The engine places schematics at generation
-- time, with no active block timers and no writes into existing saved chunks.
local function ruin_schematic()
  local blocks = {}
  for y = 1, 5 do
    for z = 1, 7 do
      for x = 1, 7 do
        local border = x == 1 or x == 7 or z == 1 or z == 7
        local corner = (x == 1 or x == 7) and (z == 1 or z == 7)
        local doorway = z == 1 and x >= 3 and x <= 5 and y >= 2
        local foundation = y == 1
        local wall = border and y <= 3
        local tower = corner and y <= 5
        local placed = (foundation or wall or tower) and not doorway
        blocks[#blocks+1] = {
          name = placed and "nv_core:cobble" or "air",
          prob = placed and 255 or 0,
        }
      end
    end
  end
  return {size = {x=7, y=5, z=7}, data = blocks}
end

core.register_decoration({
  deco_type = "schematic",
  place_on = {"nv_core:grass", "nv_world:ancient_grass"},
  sidelen = 16, fill_ratio = 0.00012,
  y_min = 5, y_max = 160,
  schematic = ruin_schematic(),
  flags = "place_center_x,place_center_z",
  rotation = "random",
})
