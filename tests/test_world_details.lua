-- Exercise actual NOVATERRA main-menu local-world info and dialog actions.
DIR_DELIM = "/"
local writes, dialogs = 0, {}
core = {
  formspec_escape = function(v)
    return (tostring(v):gsub("%[", "_"):gsub("%]", "_"):gsub(";", "_"):gsub(",", "_"))
  end,
}
local values = {
  mg_name = "v7", fixed_map_seed = "123456",
  creative_mode = "false", enable_damage = "true",
}
Settings = function(path)
  assert(path == "/local-world/world.mt")
  return {
    get = function(_, name) return values[name] end,
    set = function() writes = writes + 1; error("write forbidden") end,
    write = function() writes = writes + 1; error("write forbidden") end,
  }
end
dialog_create = function(name, formspec, handler)
  local dlg = {name=name, formspec=formspec, buttonhandler=handler, data={}}
  function dlg:delete() self.deleted=true end
  dialogs[#dialogs+1] = dlg
  return dlg
end
local info = dofile("novaterra_world_details.lua")
local world = {
  name = "World];button[0,0;1,1;bad;WRONG",
  gameid = "novaterra", path = "/local-world",
}
local f = info.formspec(world)
for _, value in ipairs({"NOVATERRA", "DETALJI SVIJETA", "v7", "123456",
                         "KREATIVNI MOD", "SURVIVAL", "NATRAG", "PODACI SVIJETA OSTAJU NA TVOM UREDAJU"}) do
  assert(f:find(value,1,true), "Missing: "..value)
end
assert(not f:find("button[0,0;1,1;bad;WRONG",1,true), "Forms injection not escaped")
assert(f:find("World__button_0_0_1_1_bad_WRONG",1,true), "Escaped world name missing")
assert(writes == 0, "Inspector changed a world")
local d = info.create_dialog(world)
assert(d and d.name == "novaterra_world_details")
assert(d.formspec(d.data):find("123456",1,true))
assert(d.buttonhandler(d,{nv_details_back=true}) == true)
assert(d.deleted, "Back button did not close dialog")
assert(info.create_dialog(nil) == nil)
assert(#dialogs == 1, "Created an unexpected dialog")
values.mg_name = nil
values.fixed_map_seed = nil
values.creative_mode = nil
local unknown = info.formspec(world)
assert(unknown:find("NIJE ZAPISAN",1,true))
assert(unknown:find("NIJE ZAPISANO",1,true))
assert(writes == 0)
print("NOVATERRA world metadata, saved mode, formspec escaping, no writes: PASS")
