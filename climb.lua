-- ia_dunce/climb.lua

----- Logic for vertical scaling of ladders, vines, and ropes.
--function ia_dunce.climb(self)
--    local pos = self.object:get_pos()
--    if medical then return false end
--
--    local node = minetest.get_node(pos)
--    local def = minetest.registered_nodes[node.name]
--
--    -- Check if the current node is climbable
--    if def and def.climbable then
--        local v = self.object:get_velocity()
--        -- Apply upward velocity; we use 2.0 as a standard climbing speed
--        self.object:set_velocity({x = v.x, y = 2.0, z = v.z})
--        ia_dunce.set_animation(self, 'CLIMB') -- Assumes CLIMB exists in your anim table
--        return true
--    end
--
--    return false
--end
--- Logic for vertical scaling of ladders, vines, and ropes.
function ia_dunce.climb(self)
	--minetest.log('ia_dunce.climb()')
    local pos = self.object:get_pos()
    if not pos then return false end

    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]

    -- Check climbable attribute or the "ladder" group
    if def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0) then
        local v = self.object:get_velocity()
        -- Upward constant velocity for climbing
        self.object:set_velocity({x = v.x, y = 2.0, z = v.z})
        
        -- Prevent animation flickering if already climbing
        if not self._is_climbing then
            ia_dunce.set_animation(self, 'CLIMB')
            self._is_climbing = true
        end
        return true
    end

    self._is_climbing = false
    return false
end
