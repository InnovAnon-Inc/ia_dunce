-- ia_dunce/bed.lua

---- Helper: Get the direction vector from param2
--local function get_direction_from_param2(param2)
--    local dirs = {
--        [0] = {x = 0, z = 1},   -- North
--        [1] = {x = 1, z = 0},   -- East
--        [2] = {x = 0, z = -1},  -- South
--        [3] = {x = -1, z = 0},  -- West
--    }
--    return dirs[param2 % 4]
--end
--
----- Makes the mob lay down, automatically adjusting for bed parts.
---- @param self The fake player object
---- @param pos The position of the node (Head, Foot, or Mat)
--function ia_dunce.lay_down(self, pos)
--	minetest.log('ia_dunce.lay_down()')
--    local node = minetest.get_node(pos)
--    local def = minetest.registered_nodes[node.name]
--    if not def then return false end
--
--    local is_mat = node.name == "sleeping_mat:mat"
--    local target_pos = vector.new(pos)
--    local dir = get_direction_from_param2(node.param2)
--
--    -- 1. Offset Logic: Find the "Head" if we clicked the "Foot"
--    -- Standard beds use groups to identify parts.
--    if not is_mat and minetest.get_item_group(node.name, "is_bed_foot") ~= 0 then
--        -- Move target_pos to the head node based on rotation
--        target_pos = vector.add(pos, dir)
--    end
--
--    -- 2. Physics & State
--    self.object:set_velocity({x = 0, y = 0, z = 0})
--    self.object:set_properties({ physical = false })
--
--    -- 3. Positioning
--    -- Mats are flat on the floor, beds are raised.
--    local height_offset = is_mat and 0.1 or 0.4
--    self.object:set_pos({x = target_pos.x, y = target_pos.y + height_offset, z = target_pos.z})
--
--    -- 4. Rotation
--    -- We want the mob to face AWAY from the headboard (laying down)
--    -- Or align with the mat's long axis.
--    local yaw = math.atan2(dir.x, dir.z) + math.pi
--    self.object:set_yaw(yaw)
--
--    -- 5. Animation (LAY sequence)
--    --self.object:set_animation({x = 162, y = 166}, 0, 0, false)
--    ia_dunce.set_animation(self, 'LAY')
--    
--    self.data.is_sleeping = true
--    return true
--end
--
--function ia_dunce.get_up(self)
--	minetest.log('ia_dunce.get_up()')
--    self.object:set_properties({ physical = true })
--    --self.object:set_animation({x = 0, y = 79}, 30, 0, true) -- STAND
--    ia_dunce.set_animation(self, 'STAND')
--
--    -- Shift them slightly so they don't spawn 'inside' the bed frame
--    local pos = self.object:get_pos()
--    self.object:set_pos({x = pos.x, y = pos.y + 0.5, z = pos.z})
--
--    self.data.is_sleeping = false
--    return true
--end

-- Helper: Get the direction vector from param2
local function get_direction_from_param2(param2)
    local dirs = {
        [0] = {x = 0, z = 1},   -- North
        [1] = {x = 1, z = 0},   -- East
        [2] = {x = 0, z = -1},  -- South
        [3] = {x = -1, z = 0},  -- West
    }
    return dirs[param2 % 4]
end

--- Internal: Finds a safe spot next to the bed to stand up.
local function find_safe_wakeup_pos(pos)
	minetest.log('ia_dunce.find_safe_wakeup_pos()')
    -- Check 4 cardinal directions around the bed
    local neighbors = {
        {x=1, y=0, z=0}, {x=-1, y=0, z=0},
        {x=0, y=0, z=1}, {x=0, y=0, z=-1}
    }
    for _, offset in ipairs(neighbors) do
        local check_pos = vector.add(pos, offset)
        local node = minetest.get_node(check_pos)
        local head_node = minetest.get_node({x=check_pos.x, y=check_pos.y+1, z=check_pos.z})

        -- If the floor is walkable and there is air for the head/body
        if ia_dunce.is_buildable(check_pos) and ia_dunce.is_buildable(head_node) then
            return check_pos
        end
    end
    return vector.add(pos, {x=0, y=0.5, z=0}) -- Fallback: pop up slightly
end

--- Makes the mob lay down, automatically adjusting for bed parts.
function ia_dunce.lay_down(self, pos)
	minetest.log('ia_dunce.lay_down()')
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
    if not def then return false end

    local is_mat = node.name == "sleeping_mat:mat"
    local target_pos = vector.new(pos)
    local dir = get_direction_from_param2(node.param2)

    -- 1. Offset Logic: Find the "Head"
    if not is_mat and minetest.get_item_group(node.name, "is_bed_foot") ~= 0 then
        target_pos = vector.add(pos, dir)
    end

    -- 2. State & Physics
    ia_dunce.stop(self)
    ia_dunce.set_lay_posture(self, true)

    -- 3. Positioning
    local height_offset = is_mat and 0.05 or 0.4
    self.object:set_pos({x = target_pos.x, y = target_pos.y + height_offset, z = target_pos.z})

    -- 4. Rotation: Align with bed axis
    local yaw = math.atan2(dir.x, dir.z) + math.pi
    self.object:set_yaw(yaw)

    self.data.is_sleeping = true
    return true
end

--- Handles waking up and clearing the bed obstruction.
function ia_dunce.get_up(self)
	minetest.log('ia_dunce.get_up()')
    if not self.data.is_sleeping then return false end

    local current_pos = self.object:get_pos()

    -- 1. Restore Physics and Animation
    ia_dunce.set_lay_posture(self, false)

    -- 2. Edge Case: Obstruction Handling
    -- Find a safe spot so we don't stand up "into" the wall or bed headboard
    local safe_pos = find_safe_wakeup_pos(vector.round(current_pos))
    self.object:set_pos(safe_pos)

    self.data.is_sleeping = false
    return true
end


--- Finds the closest bed or sleeping mat.
function ia_dunce.find_closest_bed(self, radius)
    local pos = self.object:get_pos()
    local beds = ia_dunce.get_sorted_nodes(pos, radius, {"group:bed", "sleeping_mat:mat"})
    return beds[1] -- Return closest
end
