-- NOVATERRA's first interactive screen, separate from the saved-world list.
-- Original Luanti callbacks still operate the world selection and dialogs.
local M = {}

function M.formspec(logo_file)
  local elements = {
    "box[0.00,0.00;15.5,7.1;#09151E35]",
    "box[5.20,0.41;5.10,6.32;#10242BBD]",
    "box[5.20,0.41;5.10,0.08;#D6AF71]",
    "box[5.43,1.94;4.65,0.035;#C8A369]",
    "style_type[button;bgcolor=#233B39;bgcolor_hovered=#396B51;bgcolor_pressed=#1A5740;textcolor=#FFF6DD;border=false]",
    "style[nv_continue;bgcolor=#3C9950;bgcolor_hovered=#57B56A;bgcolor_pressed=#267642;textcolor=#FFFFFF]",
    "style[nv_new;bgcolor=#337C4B;bgcolor_hovered=#499861;textcolor=#FFFFFF]",
    "style[nv_exit;bgcolor=#3E3031;bgcolor_hovered=#6B4143;textcolor=#FFFFFF]",
    "style_type[label;font=bold;textcolor=#F2D6A3]",
    -- Branded PNG is embedded from the local game menu folder.
    "label[6.03,1.64;BUILD  -  EXPLORE  -  SURVIVE]",
    "button[5.62,2.11;4.23,0.70;nv_continue;NASTAVI]",
    "button[5.62,2.92;4.23,0.70;nv_new;NOVA IGRA]",
    "button[5.62,3.73;4.23,0.70;nv_worlds;MOJI SVJETOVI]",
    "button[5.62,4.54;4.23,0.70;nv_settings;POSTAVKE]",
    "button[5.62,5.35;4.23,0.70;nv_exit;IZLAZ]",
    "label[6.20,6.31;TVOJ SVIJET. BEZ GRANICA.]",
  }
  if logo_file and logo_file ~= "" then
    elements[#elements+1] =
      "image[5.59,0.52;4.28,1.02;" .. core.formspec_escape(logo_file) .. "]"
  else
    elements[#elements+1] = "label[6.68,0.80;NOVATERRA]"
  end
  return table.concat(elements)
end

-- Continue the last actually existing offline world. A stale setting must
-- never select a deleted world or launch a different game.
function M.resume()
  local list = menudata and menudata.worldlist
  if not list then return false end
  local raw_id = tonumber(core.settings:get("mainmenu_last_selected_world"))
  if not raw_id or raw_id < 1 or raw_id ~= math.floor(raw_id) then
    return false
  end
  local world = list:get_raw_element(raw_id)
  if not world or world.gameid ~= "novaterra" then return false end
  if not world.path or world.path == "" then return false end
  local current = filterlist.get_current_index(list, raw_id)
  if not current or current < 1 then return false end

  -- Restore the world's normal options using the same engine helper as the
  -- native Play button. No save files are modified in this code.
  menu_worldmt_legacy(current)
  core.settings:set_bool("enable_server", false)
  core.settings:set("menu_last_game", "novaterra")
  gamedata.selected_world = raw_id
  gamedata.mode = "singleplayer"
  core.start()
  return true
end

return M
