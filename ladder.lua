-- ia_dunce/ladder.lua

----- Finds all ladders within a specific search area.
---- @param pos Center position.
---- @param radius Horizontal search radius.
---- @param vertical_range Vertical search range.
---- @return table List of ladder node positions.
--function ia_dunce.find_nearby_ladders(pos, radius, vertical_range)
--    local v_range = vertical_range or 2
--    local minp = vector.add(pos, {x = -radius, y = -v_range, z = -radius})
--    local maxp = vector.add(pos, {x = radius, y = v_range, z = radius})
--    
--    -- Search for nodes in the "ladder" group or specifically climbable
--    return minetest.find_nodes_in_area(minp, maxp, {"group:ladder"})
--end
--
----- Determines if a specific position contains a climbable node.
--function ia_dunce.is_climbable(pos)
--    local node = minetest.get_node(pos)
--    local def = minetest.registered_nodes[node.name]
--    return def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0)
--end
-- ia_dunce/ladder.lua

--- Low-level: Is this specific position climbable?
function ia_dunce.is_climbable(pos)
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
    return def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0)
end

--- Mid-level: Is there a ladder here and can the agent use it?
function ia_dunce.can_climb(self, pos)
    -- If no pos is provided, check the agent's current position
    local p = pos or self.object:get_pos()
    return ia_dunce.is_climbable(p)
end

--- High-level: Could the agent scale this wall if they placed ladders?
function ia_dunce.could_climb(self, pos)
    if ia_dunce.can_climb(self, pos) then return true end

    -- Check if the surface is a solid wall that accepts ladders
    -- and if we can obtain ladder items.
    local node = minetest.get_node(pos)
    local is_walkable = minetest.registered_nodes[node.name].walkable
    
    if is_walkable and ia_dunce.can_obtain_item(self, "group:ladder") then
        return true
    end

    return false
end

--- Level 1: Atomic Action (Physics)
-- Handles the actual upward movement and ledge-clearing.
function ia_dunce.climb(self)
    local pos = self.object:get_pos()
    if not pos then return false end

    if ia_dunce.is_climbable(pos) then
        local v = self.object:get_velocity()
        
        -- Check if we are at the very top of the ladder
        local above = vector.add(pos, {x=0, y=1, z=0})
        if not ia_dunce.is_climbable(above) then
            -- Push forward slightly to clear the ledge
            local yaw = self.object:get_yaw()
            local dir = {x = -math.sin(yaw), z = math.cos(yaw)}
            self.object:set_velocity({x = dir.x * 2.0, y = 2.0, z = dir.z * 2.0})
        else
            -- Standard upward climb
            self.object:set_velocity({x = v.x, y = 2.0, z = v.z})
        end
        
        if not self._is_climbing then
            ia_dunce.set_animation(self, 'CLIMB')
            self._is_climbing = true
        end
        return true
    end

    self._is_climbing = false
    return false
end

--- Level 2: Preparation + Action
-- Places a ladder from inventory and then initiates climbing.
function ia_dunce.place_and_climb(self, pos)
    minetest.log('ia_dunce.place_and_climb()')
    local is_ladder = function(n) return minetest.get_item_group(n, "ladder") > 0 end
    
    if ia_dunce.wield_by_condition(self, is_ladder) then
        if ia_dunce.right_click(self, pos, false) then
            return ia_dunce.climb(self)
        end
    end
    return false
end

--- Level 3: Provisioning + Preparation + Action
-- Crafts ladders if missing, then places and climbs.
function ia_dunce.craft_and_climb(self, pos)
    minetest.log('ia_dunce.craft_and_climb()')
    
    if not ia_dunce.has_item(self, function(n) return minetest.get_item_group(n, "ladder") > 0 end) then
        -- Default to standard wooden ladders
        if ia_dunce.can_obtain_item(self, "default:ladder_wood") then
            ia_dunce.craft_item(self, "default:ladder_wood")
        end
    end

    return ia_dunce.place_and_climb(self, pos)
end

--- Returns true if the agent is currently in a climbing state.
function ia_dunce.is_climbing(self)
    return self._is_climbing == true
end
