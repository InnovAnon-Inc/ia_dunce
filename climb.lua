-- ia_dunce/climb.lua
-- NOTE must handle climbing up & down

--------- Logic for vertical scaling of ladders, vines, and ropes.
------function ia_dunce.climb(self)
------    local pos = self.object:get_pos()
------    if medical then return false end
------
------    local node = minetest.get_node(pos)
------    local def = minetest.registered_nodes[node.name]
------
------    -- Check if the current node is climbable
------    if def and def.climbable then
------        local v = self.object:get_velocity()
------        -- Apply upward velocity; we use 2.0 as a standard climbing speed
------        self.object:set_velocity({x = v.x, y = 2.0, z = v.z})
------        ia_dunce.set_animation(self, 'CLIMB') -- Assumes CLIMB exists in your anim table
------        return true
------    end
------
------    return false
------end
------- Logic for vertical scaling of ladders, vines, and ropes.
----function ia_dunce.climb(self)
----	--minetest.log('ia_dunce.climb()')
----    local pos = self.object:get_pos()
----    if not pos then return false end
----
----    local node = minetest.get_node(pos)
----    local def = minetest.registered_nodes[node.name]
----
----    -- Check climbable attribute or the "ladder" group
----    if def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0) then
----        local v = self.object:get_velocity()
----        -- Upward constant velocity for climbing
----        self.object:set_velocity({x = v.x, y = 2.0, z = v.z})
----        
----        -- Prevent animation flickering if already climbing
----        if not self._is_climbing then
----            ia_dunce.set_animation(self, 'CLIMB')
----            self._is_climbing = true
----        end
----        return true
----    end
----
----    self._is_climbing = false
----    return false
----end
--function ia_dunce.climb(self)
--    local pos = self.object:get_pos()
--    if not pos then return false end
--
--    local node = minetest.get_node(pos)
--    local def = minetest.registered_nodes[node.name]
--
--    if def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0) then
--        local v = self.object:get_velocity()
--        
--        -- Check if we are at the very top of the ladder
--        local above = vector.add(pos, {x=0, y=1, z=0})
--        if not ia_dunce.is_climbable(above) then
--            -- We are at the top! Push forward slightly to clear the ledge
--            local yaw = self.object:get_yaw()
--            local dir = {x = -math.sin(yaw), z = math.cos(yaw)}
--            self.object:set_velocity({x = dir.x * 2, y = 2.0, z = dir.z * 2})
--        else
--            -- Standard climb
--            self.object:set_velocity({x = v.x, y = 2.0, z = v.z})
--        end
--        
--        if not self._is_climbing then
--            ia_dunce.set_animation(self, 'CLIMB')
--            self._is_climbing = true
--        end
--        return true
--    end
--
--    self._is_climbing = false
--    return false
--end
--
--function ia_dunce.is_climbing(self)
--    return self._is_climbing == true
--end
-- ia_dunce/climb.lua

--- Level 1: Atomic Action (Physics)
-- Handles upward movement, downward movement, and ledge-clearing.
-- @param target_y Optional: The altitude we want to reach.
function ia_dunce.climb(self, target_y)
    local pos = self.object:get_pos()
    if not pos then return false end

    -- Re-use is_climbable from ladder.lua if already loaded, 
    -- otherwise use local check to ensure this function is self-contained.
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
    local is_at_climbable = def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0)

    if is_at_climbable then
        local v = self.object:get_velocity()
        local my_y = pos.y
        
        -- Default to climbing UP unless a lower target is specified
        local dir_y = 1
        if target_y then
            if target_y < my_y - 0.5 then
                dir_y = -1
            elseif target_y <= my_y + 0.5 then
                dir_y = 0 -- We are roughly at the target height
            end
        end

        -- 1. Ledge Clearing (Only when moving UP)
        if dir_y > 0 then
            local above = vector.add(pos, {x=0, y=1, z=0})
            local node_above = minetest.get_node(above)
            local def_above = minetest.registered_nodes[node_above.name]
            local climbable_above = def_above and (def_above.climbable or minetest.get_item_group(node_above.name, "ladder") > 0)

            if not climbable_above then
                -- Push forward slightly to clear the ledge at the top
                local yaw = self.object:get_yaw()
                local dir = {x = -math.sin(yaw), z = math.cos(yaw)}
                self.object:set_velocity({x = dir.x * 2.0, y = 2.0, z = dir.z * 2.0})
                return true
            end
        end

        -- 2. Vertical Movement
        -- 2.0 for up, -3.0 for controlled descent
        local speed_y = 0
        if dir_y > 0 then 
            speed_y = 2.0 
        elseif dir_y < 0 then 
            speed_y = -3.0 
        end

        self.object:set_velocity({x = v.x, y = speed_y, z = v.z})
        
        -- 3. Animation State
        if not self._is_climbing then
            ia_dunce.set_animation(self, 'CLIMB')
            -- Add logging to verify the transition to climb state
            minetest.log('action', "[ia_dunce] " .. (self.mob_name or "Mob") .. " started climbing. Direction: " .. dir_y)
            self._is_climbing = true
        end
        return true
    end

    -- No longer on a climbable node
    if self._is_climbing then
        minetest.log('action', "[ia_dunce] " .. (self.mob_name or "Mob") .. " stopped climbing.")
    end
    self._is_climbing = false
    return false
end

--- Returns true if the agent is currently in a climbing state.
function ia_dunce.is_climbing(self)
    -- Explicitly checking the boolean
    return self._is_climbing == true
end
