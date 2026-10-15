-- NOVATERRA touch-first formspec layouts. All controls are bound to server-side actions.
-- Uses the exact same commands, state and gameplay logic on Android and Windows.
local M = {}
local function escape(text) return core.formspec_escape(tostring(text)) end
local function frame(title)
  return {
    "formspec_version[4]size[11.4,8.4]",
    "bgcolor[#081219F5;true]",
    "box[0.18,0.18;11.04,8.04;#17262FEE]",
    "box[0.18,0.18;11.04,0.13;#CEA35F]",
    "style_type[button;bgcolor=#233640;bgcolor_hovered=#355561;bgcolor_pressed=#CBA05C;textcolor=#FFFFFF;border=false]",
    "style_type[button_exit;bgcolor=#32434B;bgcolor_hovered=#57646A;textcolor=#FFFFFF;border=false]",
    "label[0.55,0.44;NOVATERRA]",
    "label[0.55,0.98;" .. escape(title) .. "]",
    "box[0.55,1.39;10.35,0.02;#B18B56]",
  }
end
local function done(p) return table.concat(p) end

function M.hub(player)
  local p = frame("BUILD  /  EXPLORE  /  SURVIVE  /  THRIVE")
  local buttons = {
    {"resume", "NASTAVI", 1.67},
    {"inventory", "INVENTORY", 2.51},
    {"guide", "VODIC ZA PREZIVLJAVANJE", 3.35},
    {"map", "KARTA / LOKACIJE", 4.19},
    {"quests", "ZADACI I POSTIGNUCA", 5.03},
    {"settings", "POSTAVKE", 5.87},
    {"controls", "KONTROLE", 6.71},
  }
  p[#p + 1] = "box[0.52,1.54;5.0,6.31;#0F202BDD]"
  for _, item in ipairs(buttons) do
    p[#p + 1] = string.format("button[0.72,%.2f;4.6,0.72;%s;%s]", item[3], item[1], item[2])
  end
  p[#p + 1] = "box[5.76,1.54;5.11,6.31;#101E29DA]"
  p[#p + 1] = "label[6.05,1.83;TVOJ SVIJET. BEZ GRANICA.]"
  p[#p + 1] = "label[6.05,2.43;ISTRAZI / RUDARI / GRADI]"
  p[#p + 1] = "label[6.05,2.82;PREZIVI / IGRAJ S PRIJATELJIMA]"
  local hp = player:get_hp()
  local props = player:get_properties() or {}
  local maxhp = math.max(1, props.hp_max or 20)
  local hpfraction = math.max(0, math.min(1, hp / maxhp))
  local meta = player:get_meta()
  local hunger = meta:get_int("nv_hunger")
  if meta:get_int("nv_hunger_initialized") ~= 1 then hunger = 20 end
  hunger = math.max(0, math.min(20, hunger))
  local xp = novaterra_rpg and novaterra_rpg.get_xp and novaterra_rpg.get_xp(player) or 0
  local level = novaterra_rpg and novaterra_rpg.get_level and novaterra_rpg.get_level(player) or 1
  p[#p + 1] = string.format("label[6.05,3.53;ZDRAVLJE  %d / %d]", hp, maxhp)
  p[#p + 1] = "box[6.05,4.00;4.37,0.18;#354044]"
  p[#p + 1] = string.format("box[6.05,4.00;%.2f,0.18;#D66B61]", 4.37*hpfraction)
  p[#p + 1] = string.format("label[6.05,4.51;HRANA  %d / 20]", hunger)
  p[#p + 1] = "box[6.05,4.95;4.37,0.18;#354044]"
  p[#p + 1] = string.format("box[6.05,4.95;%.2f,0.18;#E6B65E]", 4.37*hunger/20)
  p[#p + 1] = string.format("label[6.05,5.52;RAZINA  %d   /   %d XP]", level, xp)
  local pos = player:get_pos()
  if pos then
    p[#p + 1] = string.format("label[6.05,6.25;X %d   Y %d   Z %d]", math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
  end
  p[#p + 1] = "label[6.05,7.09;OTVORI IZBORNIK POMOCU KNJIGE U INVENTARU]"
  p[#p + 1] = "button_exit[8.45,7.65;2.2,0.41;close;ZATVORI]"
  return done(p)
end

function M.guide()
  local p = frame("VODIC / PRVI KORACI")
  p[#p + 1] = "box[0.6,1.7;10.15,5.53;#0E202BCF]"
  local steps = {
    "01   SAKUPI DRVO I KAMEN",
    "02   OTVORI INVENTORY I IZGRADI ALATE",
    "03   PRONADI UGLJEN I ZELJEZO U SPILJAMA",
    "04   IZGRADI PEC I ISPECI HRANU",
    "05   IZGRADI SKLONISTE I OTVORI DNEVNIK ZADATAKA",
  }
  for i, line in ipairs(steps) do
    p[#p + 1] = string.format("label[0.95,%.2f;%s]", 1.97 + (i-1)*0.84, escape(line))
  end
  p[#p + 1] = "label[0.95,6.60;ANDROID: PRITISNI I ZADRZI ZA RUDARENJE; POVUCI ZA POGLED.]"
  p[#p + 1] = "button[0.7,7.4;3.55,0.63;back;NATRAG]"
  p[#p + 1] = "button_exit[7.2,7.4;3.52,0.63;close;NASTAVI IGRU]"
  return done(p)
end

function M.controls()
  local p = frame("KONTROLE / ANDROID I WINDOWS")
  p[#p + 1] = "box[0.58,1.73;10.2,5.61;#10242DCF]"
  p[#p + 1] = "label[0.95,2.05;ANDROID]"
  p[#p + 1] = "label[0.95,2.55;Lijevi analogni krug za kretanje, povuci po zaslonu za pogled.]"
  p[#p + 1] = "label[0.95,3.05;Dodirni i zadrzi blok za rudarenje. Koristi dodirne kontrole igre.]"
  p[#p + 1] = "label[0.95,4.10;WINDOWS]"
  p[#p + 1] = "label[0.95,4.60;WASD za kretanje, mis za pogled, lijevi klik rudari.]"
  p[#p + 1] = "label[0.95,5.10;Desni klik postavlja blok, Esc otvara pauzu.]"
  p[#p + 1] = "label[0.95,6.21;NOVATERRA izbornik: /novaterra ili knjiga u inventaru.]"
  p[#p + 1] = "button[0.7,7.4;3.55,0.63;back;NATRAG]"
  p[#p + 1] = "button_exit[7.2,7.4;3.52,0.63;close;NASTAVI IGRU]"
  return done(p)
end

function M.settings(player)
  local meta = player:get_meta()
  local hud = meta:get_int("nv_hide_hud") ~= 1 and "true" or "false"
  local coords = meta:get_int("nv_show_coordinates") == 1 and "true" or "false"
  local mobile = meta:get_int("nv_classic_ui") ~= 1 and "true" or "false"
  local p = frame("POSTAVKE / SUCELJE")
  p[#p + 1] = "box[0.6,1.72;10.15,5.57;#10232CCF]"
  p[#p + 1] = "label[0.95,2.07;PRIKAZ I PRISTUPACNOST]"
  p[#p + 1] = "checkbox[0.95,2.85;hud_visible;Prikazi zdravlje i glad;" .. hud .. "]"
  p[#p + 1] = "checkbox[0.95,3.73;coordinates_visible;Prikazi koordinate;" .. coords .. "]"
  p[#p + 1] = "checkbox[0.95,4.61;mobile_interface;Koristi velike mobilne gumbe;" .. mobile .. "]"
  p[#p + 1] = "label[0.95,5.55;Postavke su sacuvane posebno za svakog igraca.]"
  p[#p + 1] = "label[0.95,6.05;Grafika i zvuk podesavaju se u postavkama Luanti enginea.]"
  p[#p + 1] = "button[0.7,7.4;3.55,0.63;back;NATRAG]"
  p[#p + 1] = "button_exit[7.2,7.4;3.52,0.63;close;NASTAVI IGRU]"
  return done(p)
end
return M
