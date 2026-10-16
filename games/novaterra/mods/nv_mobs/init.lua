-- NOVATERRA creatures: lightweight server-authoritative wilderness encounters.
-- Built from existing textures; 3D creature art remains a separate art-production task.
local MAX_ACTIVE_NEAR_PLAYER = 7
local STEP_INTERVAL = 0.35

core.register_craftitem("nv_mobs:hide", {
  description = "Animal Hide",
  inventory_image = "nv_wood.png^[colorize:#9D633C:155",
})
core.register_craftitem("nv_mobs:raw_meat", {
  description = "Raw Meat",
  inventory_image = "nv_wood.png^[colorize:#C54845:175",
})
core.register_craftitem("nv_mobs:cooked_meat", {
  description = "Cooked Meat (+8 hunger)",
  inventory_image = "nv_wood.png^[colorize:#A94F26:165",
  on_use = function(itemstack, user)
    if not user or not user:is_player() then return itemstack end
    if not novaterra_survival or not novaterra_survival.feed then return itemstack end
    if novaterra_survival.feed(user, 8) then itemstack:take_item(1) end
    return itemstack
  end,
})
core.register_craft({type = "cooking", output = "nv_mobs:cooked_meat",
  recipe = "nv_mobs:raw_meat", cooktime = 6})

local kinds = {
  grazer = {
    description = "Woodland Grazer", health = 12, speed = 1.1, damage = 0,
    drops = {"nv_mobs:hide", "nv_mobs:raw_meat 2"},
    texture = "nv_wood.png^[colorize:#BDA77C:115",
    friendly = true,
  },
  crawler = {
    description = "Cave Crawler", health = 16, speed = 1.55, damage = 2,
    drops = {"nv_world:coal"},
    texture = "nv_stone.png^nv_coal_overlay.png",
    friendly = false,
  },
  nightshade = {
    description = "Nightshade", health = 22, speed = 1.8, damage = 3,
    drops = {"nv_world:raw_iron", "nv_mobs:hide"},
    texture = "nv_leaves.png^[colorize:#442A70:140",
    friendly = false,
  },
}

local function nearest_player(pos, radius)
  local chosen, distance
  for _, player in ipairs(core.get_connected_players()) do
    if player:get_hp() > 0 then
      local p = player:get_pos()
      if p then
        local d = vector.distance(pos, p)
        if d <= radius and (not distance or d < distance) then
          chosen, distance = player, d
        end
      end
    end
  end
  return chosen, distance
end

local function move(self, direction, speed)
  if not self.object then return end
  local velocity = self.object:get_velocity()
  self.object:set_velocity({
    x = direction.x * speed,
    y = velocity.y,
    z = direction.z * speed,
  })
  self.object:set_yaw(math.atan2(-direction.x, direction.z))
end

local function stand(self)
  if not self.object then return end
  local velocity = self.object:get_velocity()
  self.object:set_velocity({x = 0, y = velocity.y, z = 0})
end

local function drop_loot(self, pos)
  if self._dropped then return end
  self._dropped = true
  local def = kinds[self.kind]
  if not def then return end
  for _, item in ipairs(def.drops) do
    core.add_item(pos, item)
  end
end

for kind, def in pairs(kinds) do
  core.register_entity("nv_mobs:" .. kind, {
    initial_properties = {
      physical = true,
      collide_with_objects = true,
      collisionbox = {-0.35, -0.45, -0.35, 0.35, 0.65, 0.35},
      visual = "cube",
      visual_size = {x = 0.8, y = 0.9},
      textures = {def.texture, def.texture, def.texture, def.texture, def.texture, def.texture},
      hp_max = def.health,
      stepheight = 1.1,
      makes_footstep_sound = true,
      static_save = true,
    },
    kind = kind,
    _step_clock = 0,
    _attack_clock = 0,
    _wander_clock = 0,
    _wander_direction = nil,
    _dropped = false,
    on_activate = function(self, staticdata)
      local hp = tonumber(staticdata)
      if hp and hp > 0 then self.object:set_hp(math.min(hp, def.health)) end
      self.object:set_acceleration({x = 0, y = -9.81, z = 0})
    end,
    get_staticdata = function(self)
      return tostring(math.max(0, self.object:get_hp()))
    end,
    on_punch = function(self, puncher)
      if self.object:get_hp() <= 0 then
        if puncher and puncher:is_player() and novaterra_rpg and novaterra_rpg.record_defeat then
          novaterra_rpg.record_defeat(puncher, self.kind)
        end
        local pos = self.object:get_pos()
        if pos then drop_loot(self, pos) end
        self.object:remove()
      end
    end,
    on_step = function(self, dtime)
      self._step_clock = self._step_clock + dtime
      self._attack_clock = self._attack_clock + dtime
      if self._step_clock < STEP_INTERVAL then return end
      local dt = self._step_clock
      self._step_clock = 0
      local pos = self.object:get_pos()
      if not pos then return end
      -- One nearby-player scan per AI tick instead of two.
      local observer, observer_distance = nearest_player(pos, 48)
      if not observer then self.object:remove(); return end
      local radius = def.friendly and 5 or 15
      local player = observer_distance <= radius and observer or nil
      local distance = observer_distance
      if player and not def.friendly then
        local destination = player:get_pos()
        if distance > 1.4 then
          local delta = vector.subtract(destination, pos)
          delta.y = 0
          if vector.length(delta) > 0.01 then move(self, vector.normalize(delta), def.speed) end
        else
          stand(self)
          if self._attack_clock >= 1.5 and player:get_hp() > 0 then
            self._attack_clock = 0
            player:punch(self.object, 1.5, {
              full_punch_interval = 1.5,
              damage_groups = {fleshy = def.damage},
            }, vector.direction(pos, destination))
          end
        end
      else
        self._wander_clock = self._wander_clock - dt
        if self._wander_clock <= 0 then
          self._wander_clock = math.random(2, 5)
          local angle = math.random() * math.pi * 2
          self._wander_direction = {x = math.cos(angle), y = 0, z = math.sin(angle)}
        end
        move(self, self._wander_direction, def.friendly and 0.45 or 0.7)
      end
    end,
  })
end

local function count_near(pos)
  local count = 0
  for _, object in ipairs(core.get_objects_inside_radius(pos, 15)) do
    local entity = object:get_luaentity()
    if entity and entity.kind and kinds[entity.kind] then count = count + 1 end
  end
  return count
end

local function spawn_above(pos, kind)
  local target = {x = pos.x, y = pos.y + 1, z = pos.z}
  local overhead = {x = pos.x, y = pos.y + 2, z = pos.z}
  if core.get_node(target).name ~= "air" or core.get_node(overhead).name ~= "air" then return end
  if not nearest_player(pos, 28) then return end
  if count_near(pos) >= MAX_ACTIVE_NEAR_PLAYER then return end
  core.add_entity({x = target.x, y = target.y + 0.4, z = target.z}, "nv_mobs:" .. kind)
end

core.register_abm({
  label = "NOVATERRA passive wildlife",
  nodenames = {"nv_core:grass"},
  interval = 45,
  chance = 120,
  catch_up = false,
  action = function(pos)
    local tod = core.get_timeofday()
    if tod > 0.23 and tod < 0.77 then spawn_above(pos, "grazer") end
  end,
})
core.register_abm({
  label = "NOVATERRA nighttime and cave encounters",
  nodenames = {"nv_core:grass", "nv_core:stone"},
  interval = 45,
  chance = 160,
  catch_up = false,
  action = function(pos)
    local tod = core.get_timeofday()
    local dark = (core.get_node_light({x=pos.x,y=pos.y+1,z=pos.z}, 0.5) or 0) <= 7
    if tod < 0.2 or tod > 0.8 or dark then
      spawn_above(pos, pos.y < -10 and "crawler" or "nightshade")
    end
  end,
})
