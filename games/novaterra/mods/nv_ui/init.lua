-- NOVATERRA in-game hub and settings.
local function esc(s) return core.formspec_escape(s) end
local function hub()
  return table.concat({
    "formspec_version[4]size[11,8]",
    "bgcolor[#09161DEB;true]",
    "box[0.2,0.2;10.6,7.6;#162A35]",
    "label[0.65,0.65;NOVATERRA]",
    "label[0.65,1.15;EXPLORE  /  BUILD  /  SURVIVE]",
    "button[0.7,2.0;4.5,0.8;guide;SURVIVAL GUIDE]",
    "button[0.7,3.0;4.5,0.8;settings;SETTINGS]",
    "button_exit[0.7,4.0;4.5,0.8;resume;RESUME GAME]",
    "label[6.0,2.0;WORLD / VOXEL SURVIVAL]",
    "label[6.0,2.6;Mine, craft and explore.]",
  })
end
local function guide()
  return table.concat({
    "formspec_version[4]size[11,8]",
    "bgcolor[#09161DEB;true]",
    "label[0.6,0.6;NOVATERRA  |  SURVIVAL GUIDE]",
    "textarea[0.65,1.2;9.8,5.8;;;",
    esc("MOVEMENT\nWASD on desktop or touch controls on Android.\n\nRESOURCES\nMine stone, coal and iron. Collect wood to craft tools.\n\nSURVIVAL\nWatch health and hunger. Eat food to restore hunger.\n\nCRAFTING\nOpen inventory to craft a pickaxe, axe, torches and furnace."),
    "]",
    "button[0.65,7.0;3.2,0.7;back;BACK]",
  })
end
local function settings(player)
  local meta=player:get_meta()
  local hud=meta:get_string("nv_hud")~="false"
  local coords=meta:get_string("nv_coordinates")=="true"
  return table.concat({
    "formspec_version[4]size[9,6.3]",
    "bgcolor[#09161DEB;true]",
    "label[0.6,0.55;NOVATERRA  |  SETTINGS]",
    "checkbox[0.8,1.6;hud_visible;Show health and hunger;",tostring(hud),"]",
    "checkbox[0.8,2.5;coordinates_visible;Show coordinates;",tostring(coords),"]",
    "label[0.8,3.6;Graphics and audio are configured in the Luanti client.]",
    "button[0.8,5.0;3.0,0.75;back;BACK]",
  })
end
local function show(player,page)
  local name=player:get_player_name()
  local form=page=="settings" and settings(player) or (page=="guide" and guide() or hub())
  core.show_formspec(name,"nv_ui:"..page,form)
end
core.register_chatcommand("novaterra",{
  description="Open NOVATERRA hub",
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false,"Player not found" end
    show(player,"hub");return true
  end,
})
core.register_chatcommand("guide",{
  description="Open survival guide",
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false,"Player not found" end
    show(player,"guide");return true
  end,
})
core.register_chatcommand("nvhud",{
  description="Toggle NOVATERRA HUD",
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false,"Player not found" end
    local enabled=player:get_meta():get_string("nv_hud")=="false"
    novaterra_survival.set_hud_visible(player,enabled)
    return true,enabled and "HUD enabled" or "HUD disabled"
  end,
})
core.register_chatcommand("nvstatus",{
  description="Show NOVATERRA survival status",
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false,"Player not found" end
    return true,"Health: "..player:get_hp().." / Hunger: "..novaterra_survival.get_hunger(player)
  end,
})
core.register_on_player_receive_fields(function(player,formname,fields)
  if type(formname)~="string" or formname:sub(1,6)~="nv_ui:" then return false end
  if fields.quit then return true end
  if fields.back then show(player,"hub");return true end
  if fields.guide then show(player,"guide");return true end
  if fields.settings then show(player,"settings");return true end
  if fields.hud_visible then
    novaterra_survival.set_hud_visible(player,fields.hud_visible=="true")
    show(player,"settings")
  end
  if fields.coordinates_visible then
    novaterra_survival.set_coordinates_visible(player,fields.coordinates_visible=="true")
    show(player,"settings")
  end
  return true
end)
