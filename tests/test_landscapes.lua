-- NOVATERRA original landscapes: real Lua registration, texture and schematic checks.
local registered = {nodes = {}, biomes = {}, decorations = {}}
core = {
  register_node = function(name, def)
    assert(not registered.nodes[name], "Duplicate landscape node: " .. name)
    registered.nodes[name] = def
  end,
  register_biome = function(def)
    assert(not registered.biomes[def.name], "Duplicate biome: " .. def.name)
    registered.biomes[def.name] = def
  end,
  register_decoration = function(def)
    registered.decorations[#registered.decorations+1] = def
  end,
}
dofile("games/novaterra/mods/nv_world/landscapes.lua")

local biomes, nodes, flowers = 0, 0, 0
local distinct_top = {}
for name, def in pairs(registered.biomes) do
  biomes = biomes + 1
  assert(name:match("^novaterra_"), "Unprefixed biome")
  assert(registered.nodes[def.node_top], "Unregistered top node: " .. def.node_top)
  assert(def.y_min < def.y_max)
  assert(type(def.heat_point) == "number" and type(def.humidity_point) == "number")
  assert(def.node_water == "nv_core:water_source")
  distinct_top[def.node_top] = true
end
for name, def in pairs(registered.nodes) do
  nodes = nodes + 1
  assert(name:match("^nv_world:"), "Outside NOVATERRA namespace")
  assert(#def.tiles >= 1 and def.tiles[1]:find("nv_", 1, true))
  if def.drawtype == "plantlike" then
    flowers = flowers + 1
    assert(def.walkable == false and def.buildable_to == true)
  end
end
local tops = 0
for _ in pairs(distinct_top) do tops = tops + 1 end
assert(biomes == 15, "Expected 15 new distinctive biomes; got " .. biomes)
assert(tops >= 12, "Biome palette lacks distinctive material surfaces")
assert(nodes == 20, "Expected 15 surfaces and five flowering plants")
assert(flowers == 5, "Missing generated flora")
assert(#registered.decorations == 6, "Expected five flora groups and one ruin scheme")

local ruins = 0
for _, decoration in ipairs(registered.decorations) do
  assert(decoration.sidelen == 16)
  assert(decoration.fill_ratio > 0)
  if decoration.deco_type == "schematic" then
    ruins = ruins + 1
    assert(decoration.fill_ratio < 0.001, "Ruin density is too expensive")
    local s = decoration.schematic
    assert(s.size.x == 7 and s.size.y == 5 and s.size.z == 7)
    assert(#s.data == 7*7*5, "The schematic grid is incomplete")
    assert(s.data[4].name == "nv_core:cobble")
    assert(s.data[49+4].prob == 0, "The ruin entrance must be open")
    for _, block in ipairs(s.data) do
      assert(block.name == "air" or block.name == "nv_core:cobble")
      assert(block.prob == 0 or block.prob == 255)
    end
  else
    assert(decoration.deco_type == "simple")
    assert(registered.nodes[decoration.decoration], "Decoration node is missing")
  end
end
assert(ruins == 1, "Expected one low-cost procedural ruin decorator")
print("NOVATERRA landscapes, 15 biomes, original plants and ruins: PASS")
