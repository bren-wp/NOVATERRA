-- Validate the actual saved-world list and read-only metadata panel.
DIR_DELIM = "/"
local selections = 1
local raw_index = "1"
local writes = 0
local config = {
  mg_name = "v7", fixed_map_seed = "987654",
  creative_mode = "false", enable_damage = "true",
}
local list = {
  {name="REAL WORLD];button[0,0;1,1;fake;FAKE", path="/saves/real", gameid="novaterra"},
  {name="ANOTHER WORLD", path="/saves/another", gameid="novaterra"},
}
core = {
  formspec_escape=function(s)
    return (tostring(s):gsub("%[","_"):gsub("%]","_"):gsub(";","_"):gsub(",","_"))
  end,
  get_textlist_index=function(key)
    assert(key=="sp_worlds")
    return selections
  end,
  settings={
    get=function(_,key)
      if key=="mainmenu_last_selected_world" then return raw_index end
      return nil
    end,
    get_bool=function(_,key) return key=="enable_damage" end,
  }
}
filterlist={get_current_index=function(_,_,raw)
  return raw
end}
Settings=function(path)
  assert(path=="/saves/real/world.mt" or path=="/saves/another/world.mt")
  return {
    get=function(_,key) return config[key] end,
    set=function() writes=writes+1; error("World inspector attempted a write") end,
  }
end
menudata={worldlist={
  get_list=function() return list end,
}}
menu_render_worldlist=function()
  return "REAL WORLD,ANOTHER WORLD"
end
novaterra_world_details=dofile("novaterra_world_details.lua")
local view=dofile("novaterra_worlds.lua")
local f=view.formspec()
for _,token in ipairs({
  "sp_worlds", "MOJI SVJETOVI", "ODABRANI SVIJET",
  "987654", "v7", "KREATIVNI", "OSTECENJA",
  ";play;IGRAJ / NASTAVI", ";world_create;NOVI SVIJET",
  ";world_configure;POSTAVKE SVIJETA", ";world_delete;OBRISI SVIJET",
  ";nv_world_info;DETALJI SVIJETA", ";nv_back_home;NATRAG",
}) do
  assert(f:find(token,1,true),"Missing working NOVATERRA form element: "..token)
end
assert(not f:find("button[0,0;1,1;fake;FAKE",1,true),
       "User-controlled world name escaped its field")
assert(writes==0, "The summary must not modify world.mt")

-- Deleted or unselected worlds show only valid actions (New and Back).
selections=nil
raw_index="999"
local empty=view.formspec()
assert(empty:find("NOVI SVIJET",1,true))
assert(empty:find("IZABERI SVIJET",1,true))
assert(not empty:find(";play;",1,true))
assert(not empty:find(";world_delete;",1,true))
assert(not empty:find(";world_configure;",1,true))
assert(not empty:find(";nv_world_info;",1,true))

-- Missing metadata must display absence rather than made-up dates / previews.
selections=1
config.fixed_map_seed=nil
config.mg_name=nil
local unknown=view.formspec()
assert(unknown:find("NIJE ZAPISAN",1,true))
assert(not unknown:find("thumbnail",1,true))
assert(not unknown:find("12.10.2026",1,true))
assert(writes==0)
print("NOVATERRA true local world list / metadata / safe buttons PASS")
