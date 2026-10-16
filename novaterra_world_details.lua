-- NOVATERRA / Local world information. Read-only: no save data mutations.
local M = {}
local function esc(value)
  return core.formspec_escape(tostring(value or ""))
end
local function local_settings(world)
  if not world or type(world.path) ~= "string" or world.path == "" then
    return nil
  end
  local ok, value = pcall(Settings, world.path .. DIR_DELIM .. "world.mt")
  return ok and value or nil
end
local function get(settings, name)
  if not settings then return nil end
  local ok, result = pcall(function() return settings:get(name) end)
  if ok and type(result) == "string" and result ~= "" then return result end
  return nil
end
local function yn(value)
  if value == "true" then return "DA" end
  if value == "false" then return "NE" end
  return "NIJE ZAPISANO"
end
function M.formspec(world)
  assert(world and type(world.name) == "string", "Selected world required")
  local cfg = local_settings(world)
  local mg = get(cfg, "mg_name") or "NIJE ZAPISAN"
  local seed = get(cfg, "fixed_map_seed") or "NIJE ZAPISAN"
  local creative = yn(get(cfg, "creative_mode"))
  local damage = yn(get(cfg, "enable_damage"))
  return table.concat({
    "formspec_version[4]size[10.4,7.75]",
    "bgcolor[#09161FF5;true]",
    "box[0.18,0.18;10.04,7.39;#122733F0]",
    "box[0.18,0.18;10.04,0.10;#CA9F61]",
    "style_type[button_exit;bgcolor=#388D49;bgcolor_hovered=#58AE66;textcolor=#FFFFFF;border=false]",
    "label[0.58,0.55;NOVATERRA  /  DETALJI SVIJETA]",
    "box[0.55,1.18;9.3,1.05;#1F3946D9]",
    "label[0.78,1.31;NAZIV SVIJETA]",
    "textarea[0.73,1.66;8.65,0.48;;;" .. esc(world.name) .. "]",
    "label[0.78,2.55;IGRA]",
    "label[5.35,2.55;GENERATOR TERENA]",
    "label[0.78,3.08;" .. esc(world.gameid or "novaterra") .. "]",
    "label[5.35,3.08;" .. esc(mg) .. "]",
    "box[0.55,3.65;9.3,0.03;#B99258]",
    "label[0.78,4.01;SJEME GENERIRANJA]",
    "textarea[0.74,4.40;8.67,0.52;;;" .. esc(seed) .. "]",
    "label[0.78,5.23;KREATIVNI MOD]",
    "label[5.35,5.23;OSTECENJA / SURVIVAL]",
    "label[0.78,5.73;" .. esc(creative) .. "]",
    "label[5.35,5.73;" .. esc(damage) .. "]",
    "label[0.78,6.37;PODACI SVIJETA OSTAJU NA TVOM UREDAJU]",
    "button_exit[3.75,6.86;2.9,0.54;nv_details_back;NATRAG]",
  })
end
function M.create_dialog(world)
  if not world or type(world.name) ~= "string" or world.name == "" then
    return nil
  end
  local dialog = dialog_create("novaterra_world_details", function(data)
    return M.formspec(data.world)
  end, function(this, fields)
    if fields.nv_details_back or fields.quit then
      this:delete()
      return true
    end
    return false
  end, nil)
  dialog.data.world = {name = world.name, path = world.path, gameid = world.gameid}
  return dialog
end
return M
