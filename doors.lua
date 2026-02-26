---- ia_dunce/doors.lua
--
----- Internal Helper: Interacts with a door at a given position.
---- @param pos The position of the door node.
---- @param state boolean: true to open, false to close, nil to toggle.
---- @return boolean (Success)
--local function set_door_state(pos, state)
--	minetest.log('ia_dunce.set_door_state()')
--    if not minetest.get_modpath("doors") then return false end
--    
--    local door = doors.get(pos)
--    if not door then return false end
--
--    -- door:state() returns true if open
--    local current_state = door:state()
--    
--    if state == nil then
--        -- Toggle
--        if current_state then door:close() else door:open() end
--        return true
--    elseif state ~= current_state then
--        -- Set specific state
--        if state then door:open() else door:close() end
--        return true
--    end
--    
--    return false -- Already in the desired state
--end
--
----- Scans for and handles doors in front of the Dunce.
---- @param self The fake player object.
---- @param action "open", "close", or "toggle"
---- @return boolean (Whether an interaction occurred)
--function ia_dunce.handle_door_front(self, action)
--	minetest.log('ia_dunce.handle_door_front()')
--    -- We look exactly 1 block ahead
--    local front_pos = ia_dunce.get_relative_node_pos(self, 1)
--    local node = minetest.get_node(front_pos)
--    
--    -- Check if it's actually a door (using groups is better than string.find)
--    if minetest.get_item_group(node.name, "door") > 0 then
--        local state_map = {open = true, close = false, toggle = nil}
--        return set_door_state(front_pos, state_map[action])
--    end
--    
--    return false
--end
--
----- Specifically handles closing a door behind the Dunce.
--function ia_dunce.close_door_behind(self)
--	minetest.log('ia_dunce.close_door_behind()')
--    local back_pos = ia_dunce.get_relative_node_pos(self, -1)
--    local node = minetest.get_node(back_pos)
--    
--    if minetest.get_item_group(node.name, "door") > 0 then
--        return set_door_state(back_pos, false)
--    end
--    
--    return false
--end
--- Internal Helper: Interacts with a door at a given position.
local function set_door_state(pos, state)
	minetest.log('ia_dunce.set_door_state()')
    if not minetest.get_modpath("doors") then return false end
    
    local door = doors.get(pos)
    if not door then return false end

    local current_state = door:state()
    
    if state == nil then
        if current_state then door:close() else door:open() end
        return true
    elseif state ~= current_state then
        if state then door:open() else door:close() end
        return true
    end
    
    return false
end

--- Logic for deciding if a door is safe to close (checks for other mobs).
local function is_doorway_clear(pos)
	minetest.log('ia_dunce.is_doorway_clear()')
    -- Small radius check: is anyone standing in the frame?
    local objects = minetest.get_objects_inside_radius(pos, 0.8)
    -- If more than 0 objects (the caller is already > 1.2 away), it's blocked
    return #objects == 0
end

--- Scans for and handles doors in front of the Dunce.
function ia_dunce.handle_door_front(self, action)
	minetest.log('ia_dunce.handle_door_front()')
    local front_pos = ia_dunce.get_relative_node_pos(self, 1)
    local node = minetest.get_node(front_pos)
    
    if minetest.get_item_group(node.name, "door") > 0 then
        -- Track this door so the movement system knows we are currently "in" a doorway
        self._active_door_pos = vector.new(front_pos)
        
        local state_map = {open = true, close = false, toggle = nil}
        return set_door_state(front_pos, state_map[action])
    end
    
    return false
end

--- Checks if the Dunce has cleared the last door and closes it if the coast is clear.
function ia_dunce.process_door_cleanup(self)
	--minetest.log('ia_dunce.process_door_cleanup()')
    if not self._active_door_pos then return end

    local my_pos = self.object:get_pos()
    if not my_pos then return end

    -- 1. Check if we have moved far enough away (cleared the hitbox)
    local dist = vector.distance(my_pos, self._active_door_pos)
    
    if dist > 1.3 then
        -- 2. Future-proofing: Only close if no one else is currently passing through
        if is_doorway_clear(self._active_door_pos) then
            set_door_state(self._active_door_pos, false)
            self._active_door_pos = nil -- Task complete
        end
    end

    -- 3. Edge Case: If we wandered 5+ blocks away without closing it (path changed), 
    -- just forget about it to prevent "ghost closing" later.
    if dist > 5.0 then
        self._active_door_pos = nil
    end
end




















--function ia_dunce.find_nearby_doors(pos) -- TODO xref against sensors
--    local doors_found = {}
--    -- Search 2 nodes up and 1 node down for door groups
--    local minp = vector.add(pos, {x=-1, y=-1, z=-1})
--    local maxp = vector.add(pos, {x=1, y=2, z=1})
--    local nodes = minetest.find_nodes_in_area(minp, maxp, {"group:door"})
--    
--    for _, p in ipairs(nodes) do
--        table.insert(doors_found, p)
--    end
--    return doors_found
--end
function ia_dunce.find_nearby_doors(pos, radius)
    local r = radius or 2
    return get_sorted_nodes(pos, r, {"group:door"})
end
