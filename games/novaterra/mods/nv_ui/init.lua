-- NOVATERRA in-game hub. No client-supplied player names or privileged actions.
local FORM = 'nv_ui:hub'
local GUIDE = 'nv_ui:guide'
local INVENTORY = 'nv_ui:inventory'
local SETTINGS = 'nv_ui:settings'
local function esc(s) return core.formspec_escape(s) end
local function hub()
  return table.concat({
    'formspec_version[4]size[11,8.5]',
    'bgcolor[#09151EF4;true]',
    'box[0.25,0.25;10.5,8;#12252BEF]',
    'box[0.25,0.25;10.5,0.14;#C99B51]',
    'label[0.8,0.85;NOVATERRA]',
    'label[0.8,1.45;BUILD  /  EXPLORE  /  SURVIVE  /  THRIVE]',
    'button[0.8,2.15;4.4,0.85;resume;NASTAVI]',
    'button[0.8,3.15;4.4,0.85;inventory;INVENTORY]',
    'button[0.8,4.15;4.4,0.85;guide;VODIC ZA PREZIVLJAVANJE]',
    'button[0.8,5.15;4.4,0.85;map;MAP / WAYPOINT]',
    'button[0.8,6.15;2.1,0.75;controls;KONTROLE]',
    'button[3.0,6.15;2.2,0.75;settings;POSTAVKE]',
    'button[5.8,6.15;4.35,0.75;quests;ZADACI I POSTIGNUCA]',
    'label[5.8,2.4;NOVATERRA / SURVIVAL WORLD]',
    'textarea[5.8,3;4.3,2.8;;;' .. esc('Svjetovi, multiplayer i postavke dostupni su u Luanti glavnom izborniku. Ovaj ekran je izbornik unutar igre.') .. ']',
    'button_exit[3.8,7.1;3.4,0.8;close;POVRATAK U IGRU]',
  })
end
local function guide()
  return table.concat({
    'formspec_version[4]size[10.5,8.4]',
    'bgcolor[#09161DF5;true]',
    'box[0.25,0.25;10,7.9;#15262DEE]',
    'label[0.7,0.65;NOVATERRA  /  SURVIVAL GUIDE]',
    'label[0.7,1.5;1. Gather wood and stone by mining blocks.]',
    'label[0.7,2.2;2. Open inventory and craft your first tools.]',
    'label[0.7,2.9;3. Build a shelter before exploring caves.]',
    'label[0.7,3.6;4. Craft trail rations to restore hunger.]',
    'label[0.7,4.3;5. Place torches to illuminate dark areas.]',
    'label[0.7,5.35;ANDROID: use the Luanti touch controls.]',
    'label[0.7,5.9;WINDOWS: use keyboard and mouse controls.]',
    'button[0.8,7;3,0.8;back;BACK TO MENU]',
    'button_exit[6.2,7;3.2,0.8;close;CLOSE]',
  })
end
local function controls()
  return table.concat({
    'formspec_version[4]size[10,6]',
    'bgcolor[#09161DF5;true]',
    'box[0.2,0.2;9.6,5.6;#15262DEE]',
    'label[0.6,0.8;NOVATERRA  /  CONTROLS]',
    'textarea[0.6,1.4;8.8,2.9;;;WINDOWS: WASD to move, mouse to look, left click to mine, right click to place.\nANDROID: use Luanti touch controls, tap and hold to mine.\nInventory: use the Luanti inventory button or keyboard shortcut.]',
    'button[0.6,4.6;3.2,0.8;back;BACK TO MENU]',
    'button_exit[6,4.6;3.2,0.8;close;CLOSE]',
  })
end
local function settings(player)
  local hidden = player:get_meta():get_int('nv_hide_hud') == 1
  local coords = player:get_meta():get_int('nv_show_coordinates') == 1
  return table.concat({
    'formspec_version[4]size[9,6.3]',
    'bgcolor[#09151EF4;true]',
    'box[0.25,0.25;8.5,5.8;#12252BEF]',
    'box[0.25,0.25;8.5,0.12;#C99B51]',
    'label[0.7,0.85;NOVATERRA / POSTAVKE]',
    'label[0.7,1.7;SURVIVAL HUD]',
    'checkbox[0.8,2.45;hud_visible;Prikazi zdravlje i glad;', hidden and 'false' or 'true', ']',
    'checkbox[0.8,3.3;coordinates_visible;Prikazi koordinate;', coords and 'true' or 'false', ']',
    'label[0.7,4.0;Promjene se spremaju za ovog igraca.]',
    'button[0.7,4.8;3,0.85;back;NATRAG]',
    'button_exit[5.3,4.8;3,0.85;close;ZATVORI]',
  })
end
-- Mobile layouts share the same server-side callbacks as desktop formspecs.
local classic_hub, classic_guide, classic_controls, classic_settings = hub, guide, controls, settings
local touch = dofile(core.get_modpath('nv_ui') .. '/mobile.lua')
local function touch_enabled(player)
  return player and player:get_meta():get_int('nv_classic_ui') ~= 1
end
hub = function(player)
  return touch_enabled(player) and touch.hub(player) or classic_hub()
end
guide = function()
  return touch.guide()
end
controls = function()
  return touch.controls()
end
settings = function(player)
  return touch_enabled(player) and touch.settings(player) or classic_settings(player)
end

local function show(player, name, spec)
  if player and player:is_player() then core.show_formspec(player:get_player_name(), name, spec) end
end
local function show_inventory(player)
  -- Server-side inventory formspec: all lists are bound to the current player.
  show(player, INVENTORY, player:get_inventory_formspec())
end
local function show_hub(player) show(player, FORM, hub(player)) end
core.register_chatcommand('novaterra', {
  description='Open the NOVATERRA in-game menu',
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false, 'Player not connected' end
    show_hub(player)
    return true
  end,
})
core.register_chatcommand('guide', {
  description='Open the NOVATERRA survival guide',
  func=function(name)
    local player=core.get_player_by_name(name)
    if not player then return false, 'Player not connected' end
    show(player, GUIDE, guide())
    return true
  end,
})
core.register_on_player_receive_fields(function(player, formname, fields)
  if not player or not player:is_player() then return end
  if (formname == '' or formname == INVENTORY) and fields.nv_menu then
    show_hub(player)
    return
  end
  if (formname == '' or formname == INVENTORY) and fields.nv_quests then
    if novaterra_rpg and novaterra_rpg.show then novaterra_rpg.show(player) end
    return
  end
  if (formname == '' or formname == INVENTORY) and fields.nv_guide then
    show(player, GUIDE, guide())
    return
  end
  if formname ~= FORM and formname ~= GUIDE and formname ~= 'nv_ui:controls' and formname ~= INVENTORY and formname ~= SETTINGS then return end
  if fields.resume then
    core.close_formspec(player:get_player_name(), formname)
    return
  end
  if fields.quit or fields.close then return end
  if formname == SETTINGS and fields.mobile_interface then
    player:get_meta():set_int('nv_classic_ui', fields.mobile_interface == 'true' and 0 or 1)
    show(player, SETTINGS, settings(player))
    return
  end
  if formname == SETTINGS and fields.coordinates_visible then
    if novaterra_survival and novaterra_survival.set_coordinates_visible then
      novaterra_survival.set_coordinates_visible(player, fields.coordinates_visible == 'true')
    end
    show(player, SETTINGS, settings(player))
    return
  end
  if formname == SETTINGS and fields.hud_visible then
    local visible = fields.hud_visible == 'true'
    player:get_meta():set_int('nv_hide_hud', visible and 0 or 1)
    if novaterra_survival and novaterra_survival.set_hud_visible then
      novaterra_survival.set_hud_visible(player, visible)
    end
    show(player, SETTINGS, settings(player))
    return
  end
  if fields.back then show_hub(player)
  elseif formname == FORM and fields.guide then show(player, GUIDE, guide())
  elseif formname == FORM and fields.map then
    core.close_formspec(player:get_player_name(), FORM)
    core.chatcommands.nvmap.func(player:get_player_name())
  elseif formname == FORM and fields.quests then
    if novaterra_rpg and novaterra_rpg.show then novaterra_rpg.show(player) end
  elseif formname == FORM and fields.controls then show(player, 'nv_ui:controls', controls())
  elseif formname == FORM and fields.settings then show(player, SETTINGS, settings(player))
  elseif formname == FORM and fields.inventory then
    show_inventory(player)
  end
end)
-- A useable inventory tool is a reliable touch-screen entry point.
-- Unlike a decorative HUD image, tapping this item really opens the menu.
core.register_craftitem('nv_ui:field_manual', {
  description = 'NOVATERRA / Main Menu',
  inventory_image = 'nv_glass.png^[colorize:#59C7AE:140',
  stack_max = 1,
  on_use = function(itemstack, user)
    if user and user:is_player() then show_hub(user) end
    return itemstack
  end,
})
core.register_craft({output = 'nv_ui:field_manual',
  recipe = {{'nv_core:glass', 'nv_core:wood'}}})
core.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  core.chat_send_player(name, 'NOVATERRA: tap the Main Menu item or type /novaterra to open the game menu.')
  local meta = player:get_meta()
  if meta:get_int('nv_mobile_intro_shown') == 0 then
    meta:set_int('nv_mobile_intro_shown', 1)
    local inventory = player:get_inventory()
    if not inventory:contains_item('main', 'nv_ui:field_manual') then
      inventory:add_item('main', 'nv_ui:field_manual')
    end
    -- Delay until other modules have finished their join callbacks.
    core.after(0.7, function()
      local current = core.get_player_by_name(name)
      if current and current:is_player() then show_hub(current) end
    end)
  end
end)

-- Lightweight cross-platform world status: no extra touch buttons or UI overlap.
core.register_chatcommand('nvstatus', {
  description = 'Show NOVATERRA position and in-game time',
  func = function(name)
    local player = core.get_player_by_name(name)
    if not player then return false, 'Player not connected' end
    local pos = player:get_pos()
    local time = core.get_timeofday() or 0
    local hour = math.floor(time * 24) % 24
    local minute = math.floor((time * 24 - math.floor(time * 24)) * 60)
    return true, string.format('NOVATERRA | X %.0f  Y %.0f  Z %.0f | %02d:%02d', pos.x, pos.y, pos.z, hour, minute)
  end,
})
