-- Exercise real NOVATERRA menu callbacks; no dead touch controls permitted.
local receiver, shown, closed, openedMap, openedQuests = nil, nil, nil, false, false
local commands, craftItems = {}, {}
local metaData = {nv_hunger_initialized=1, nv_hunger=16}
local meta = {
  get_int = function(_, name) return metaData[name] or 0 end,
  set_int = function(_, name, value) metaData[name] = value end,
}
local player = {
  get_player_name = function() return 'UItester' end,
  is_player = function() return true end,
  get_meta = function() return meta end,
  get_hp = function() return 20 end,
  get_pos = function() return {x=1,y=22,z=3} end,
  get_properties = function() return {hp_max=20} end,
  get_inventory_formspec = function() return 'formspec_version[4]size[8,8]' end,
}
core = {
  get_modpath = function() return 'games/novaterra/mods/nv_ui' end,
  formspec_escape = function(v) return tostring(v) end,
  register_chatcommand = function(name, def) commands[name] = def end,
  register_craftitem = function(name, def) craftItems[name] = def end,
  register_craft = function() end,
  register_on_joinplayer = function() end,
  register_on_player_receive_fields = function(fn) receiver = fn end,
  get_player_by_name = function() return player end,
  show_formspec = function(name, formname, spec)
    shown = {name=name, formname=formname, spec=spec}
  end,
  close_formspec = function(name, formname)
    closed = {name=name, formname=formname}
  end,
}
novaterra_survival = {
  set_hud_visible = function() return true end,
  set_coordinates_visible = function() return true end,
}
novaterra_rpg = {
  get_level = function() return 2 end,
  get_xp = function() return 165 end,
  show = function() openedQuests = true end,
}
commands.nvmap = {func = function() openedMap = true end}
dofile('games/novaterra/mods/nv_ui/init.lua')
assert(receiver ~= nil, 'Receive-fields callback is missing')
local function press(form, fields) receiver(player, form, fields) end
commands.novaterra.func('UItester')
assert(shown and shown.formname == 'nv_ui:hub')
assert(shown.spec:find('NASTAVI', 1, true))
press('nv_ui:hub', {resume=true})
assert(closed and closed.formname == 'nv_ui:hub', 'Continue was a dead button')
press('nv_ui:hub', {inventory=true})
assert(shown.formname == 'nv_ui:inventory', 'Inventory button did not open inventory')
press('nv_ui:hub', {guide=true})
assert(shown.formname == 'nv_ui:guide', 'Guide button did not open')
press('nv_ui:hub', {controls=true})
assert(shown.formname == 'nv_ui:controls', 'Controls button did not open')
press('nv_ui:hub', {settings=true})
assert(shown.formname == 'nv_ui:settings', 'Settings button did not open')
press('nv_ui:settings', {coordinates_visible='true'})
assert(metaData.nv_show_coordinates == 1, 'Coordinate toggle did not persist')
press('nv_ui:settings', {hud_visible='false'})
assert(metaData.nv_hide_hud == 1, 'HUD visibility toggle did not persist')
press('nv_ui:hub', {quests=true})
assert(openedQuests, 'Quests button did not invoke the RPG journal')
press('nv_ui:hub', {map=true})
assert(openedMap, 'World map button did not open the world map')
assert(craftItems['nv_ui:field_manual'], 'Touch menu item was not registered')
craftItems['nv_ui:field_manual'].on_use({}, player)
assert(shown.formname == 'nv_ui:hub', 'Useable menu item did not open the hub')
press('', {nv_menu=true})
assert(shown.formname == 'nv_ui:hub', 'Inventory menu button did not open hub')
print('NOVATERRA Android touch menu: all primary interactive actions PASS')
