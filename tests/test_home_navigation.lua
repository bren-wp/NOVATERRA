-- Actual NOVATERRA home-screen Lua controller, not an image prototype.
local count = {started=0,settings=0}
local stored = {mainmenu_last_selected_world="2"}
local worlds = {
  [1]={gameid="novaterra",path="/worlds/one"},
  [2]={gameid="novaterra",path="/worlds/two"},
}
core = {
  settings = {
    get=function(_,k) return stored[k] end,
    set=function(_,k,v) stored[k]=v;count.settings=count.settings+1 end,
    set_bool=function(_,k,v) stored[k]=v;count.settings=count.settings+1 end,
  },
  start=function() count.started=count.started+1 end,
}
menudata={worldlist={
  get_raw_element=function(_,id) return worlds[id] end,
}}
filterlist={get_current_index=function(_,id) return id end}
gamedata={}
menu_worldmt_legacy=function(id) assert(id==2); count.mode=id end
local home=dofile("novaterra_home.lua")
local f=home.formspec()
for _,item in ipairs({"NOVATERRA", "NASTAVI", "NOVA IGRA", "MOJI SVJETOVI",
                        "POSTAVKE", "IZLAZ", "TVOJ SVIJET. BEZ GRANICA."}) do
  assert(f:find(item,1,true),item.." missing on home")
end
for _,id in ipairs({"nv_continue","nv_new","nv_worlds","nv_settings","nv_exit"}) do
  assert(f:find(";"..id..";",1,true),"Missing real action field "..id)
end
for _,bad in ipairs({"OFFLINE ADVENTURE","MULTIPLAYER","WINDOWS","DEBUG"}) do
  assert(not f:find(bad,1,true),"Leaked technical or unsupported UI: "..bad)
end
assert(home.resume())
assert(count.started==1 and gamedata.selected_world==2)
assert(gamedata.mode=="singleplayer")
assert(stored.enable_server==false)
assert(stored.menu_last_game=="novaterra")
assert(count.mode==2)
stored.mainmenu_last_selected_world="999"
assert(not home.resume(),"Stale selection must never launch")
assert(count.started==1)
stored.mainmenu_last_selected_world="bad"
assert(not home.resume(),"Malformed selection must never launch")
stored.mainmenu_last_selected_world="1"
worlds[1]={gameid="other_game",path="/worlds/foreign"}
assert(not home.resume(),"Must not start another game")
stored.mainmenu_last_selected_world="2"
worlds[2]={gameid="novaterra",path=""}
assert(not home.resume(),"Invalid world directory")
assert(count.started==1)
print("NOVATERRA home and saved world Resume contract: PASS")
