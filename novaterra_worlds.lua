-- NOVATERRA: native Android world list with a real selected-world summary.
-- Presentation only: Luanti still handles create/play/configure/confirm-delete.
local M = {}

local function esc(text)
  return core.formspec_escape(tostring(text or ""))
end

local function selected_world()
  local listing = menudata and menudata.worldlist
  if not listing then return nil, 0 end
  local worlds = listing:get_list() or {}
  local index = core.get_textlist_index("sp_worlds")
  if not index or index < 1 then
    local previous = tonumber(core.settings:get("mainmenu_last_selected_world"))
    if previous and filterlist and filterlist.get_current_index then
      index = filterlist.get_current_index(listing, previous)
    end
  end
  index = tonumber(index) or 0
  if index < 1 then return nil, 0 end
  index = math.min(index, #worlds)
  if index < 1 then return nil, 0 end
  return worlds[index], index
end

function M.formspec()
  local world, index = selected_world()
  local parts = {
    "box[0.0,0.0;15.5,7.1;#09161F78]",
    "box[0.25,0.24;6.15,6.64;#10262CCC]",
    "box[6.62,0.24;8.63,6.64;#152A32DD]",
    "box[0.25,0.24;15.00,0.09;#C9A060]",
    "box[0.55,0.57;0.10,0.51;#67D079]",
    "style_type[button;bgcolor=#253B3D;bgcolor_hovered=#386358;bgcolor_pressed=#1D4A36;textcolor=#F8F1DB;border=false]",
    "style[world_create;bgcolor=#34844B;bgcolor_hovered=#4D9E62;textcolor=#FFFFFF]",
    "style[play;bgcolor=#388F48;bgcolor_hovered=#5AAD63;textcolor=#FFFFFF]",
    "style[world_delete;bgcolor=#563D3B;bgcolor_hovered=#784747;textcolor=#FFF2E2]",
    "style[nv_back_home;bgcolor=#263E49;bgcolor_hovered=#426473;textcolor=#FFFFFF]",
    "label[0.77,0.54;NOVATERRA / MOJI SVJETOVI]",
    "label[6.96,0.54;ODABRANI SVIJET]",
    "box[0.61,1.00;5.43,0.025;#BC985F]",
    "box[6.96,1.00;7.95,0.025;#BC985F]",
    "button[0.60,5.95;2.75,0.73;world_create;NOVI SVIJET]",
    "button[3.50,5.95;2.65,0.73;nv_back_home;NATRAG]",
  }
  -- This is the real engine world list, not a fabricated set of menu cards.
  -- Luanti's menu_render_worldlist() provides the canonical escaped names.
  parts[#parts+1] = "textlist[0.63,1.30;5.70,4.30;sp_worlds;" ..
    menu_render_worldlist() .. ";" .. index .. ";false]"

  if not world then
    parts[#parts+1] = "label[7.07,1.62;JOS NEMA ODABRANOG SVIJETA]"
    parts[#parts+1] = "label[7.07,2.28;IZABERI SVIJET S POPISA]"
    parts[#parts+1] = "label[7.07,2.83;ILI STVORI NOVU AVANTURU]"
    parts[#parts+1] = "box[7.05,3.50;7.65,0.025;#BC985F]"
    parts[#parts+1] = "label[7.07,4.03;SVI PODACI POHRANJUJU SE LOKALNO]"
    return table.concat(parts)
  end

  local details = novaterra_world_details.read(world)
  parts[#parts+1] = "label[7.02,1.28;NAZIV SVIJETA]"
  parts[#parts+1] = "textarea[6.98,1.65;7.75,0.78;;;" .. esc(details.name) .. "]"
  parts[#parts+1] = "label[7.04,2.54;SJEME GENERIRANJA]"
  parts[#parts+1] = "label[11.14,2.54;GENERATOR]"
  parts[#parts+1] = "textarea[7.00,2.85;3.85,0.73;;;" .. esc(details.seed) .. "]"
  parts[#parts+1] = "textarea[11.07,2.85;3.60,0.73;;;" .. esc(details.mapgen) .. "]"
  parts[#parts+1] = "label[7.04,3.80;NACIN IGRE]"
  parts[#parts+1] = "checkbox[7.04,4.29;cb_creative_mode;KREATIVNI;" ..
    tostring(core.settings:get_bool("creative_mode")) .. "]"
  parts[#parts+1] = "checkbox[10.75,4.29;cb_enable_damage;OSTECENJA;" ..
    tostring(core.settings:get_bool("enable_damage")) .. "]"
  parts[#parts+1] = "button[6.99,5.12;3.52,0.66;nv_world_info;DETALJI SVIJETA]"
  parts[#parts+1] = "button[10.69,5.12;4.08,0.66;world_configure;POSTAVKE SVIJETA]"
  parts[#parts+1] = "button[6.99,5.95;3.80,0.77;play;IGRAJ / NASTAVI]"
  parts[#parts+1] = "button[10.97,5.95;3.80,0.77;world_delete;OBRISI SVIJET]"
  return table.concat(parts)
end

return M
