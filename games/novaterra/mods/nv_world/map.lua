-- NOVATERRA world information and lightweight waypoint navigation.
local function esc(value) return core.formspec_escape(tostring(value)) end
local function fmt(pos)
  return string.format('X %d  Y %d  Z %d', math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
end
local function form(player)
  local pos=player:get_pos()
  local meta=player:get_meta()
  local waypoint=meta:get_string('nv_waypoint')
  if waypoint=='' then waypoint='No waypoint saved' end
  return table.concat({
    'formspec_version[4]size[10,7.6]',
    'bgcolor[#09151EF4;true]',
    'box[0.25,0.25;9.5,7.1;#12252BEF]',
    'box[0.25,0.25;9.5,0.13;#C99B51]',
    'label[0.7,0.75;NOVATERRA / WORLD MAP]',
    'label[0.7,1.5;CURRENT POSITION]',
    'label[0.7,2.0;',esc(fmt(pos)),']',
    'label[0.7,2.9;SAVED WAYPOINT]',
    'label[0.7,3.4;',esc(waypoint),']',
    'button[0.7,4.3;4.0,0.8;save;SAVE CURRENT LOCATION]',
    'button[5.0,4.3;4.0,0.8;clear;CLEAR WAYPOINT]',
    'label[0.7,5.5;The map uses coordinates; graphical terrain map is not yet available.]',
    'button_exit[0.7,6.4;3.5,0.75;close;CLOSE]',
  })
end
local function show(player)
  core.show_formspec(player:get_player_name(),'nv_world:map',form(player))
end
core.register_chatcommand('nvmap',{
  description='Show NOVATERRA position and saved waypoint',
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false,'Player not connected' end
    show(player)
    return true
  end,
})
core.register_on_player_receive_fields(function(player,formname,fields)
  if formname~='nv_world:map' or not player or not player:is_player() then return false end
  if fields.quit or fields.close then return true end
  if fields.save then
    player:get_meta():set_string('nv_waypoint',fmt(player:get_pos()))
    show(player)
  elseif fields.clear then
    player:get_meta():set_string('nv_waypoint','')
    show(player)
  end
  return true
end)
