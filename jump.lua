-- ia_dunce/jump.lua
--
----- Logic for vertical leaps and climbing.
--function ia_dunce.jump(self)
--	minetest.log('ia_dunce.jump()')
--    local pos = self.object:get_pos()
--    if not pos then return false end
--
--    local below = {x = pos.x, y = pos.y - 0.1, z = pos.z}
--    local node_below = minetest.get_node(below)
--    local v = self.object:get_velocity()
--
--    -- Only jump if standing on a walkable surface and not already ascending/descending
--    local is_walkable = ia_dunce.get_node_properties(node_below.name)
--    if is_walkable and math.abs(v.y) < 0.1 then
--        ia_dunce.apply_vertical_impulse(self, 5) -- Standard 1.1 block jump height
--        return true
--    end
--    
--    return false
--end
-- ia_dunce/jump.lua

--- Checks if the mob can and should jump to reach a specific target pos.
-- @param target_pos The position we are trying to reach.
function ia_dunce.can_jump_to(self, target_pos)
    local pos = self.object:get_pos()
    if not pos then return false end

    -- 1. Is the target actually higher than us?
    if target_pos.y <= pos.y + 0.1 then return false end

    -- 2. Are we standing on solid ground?
    local below = {x = pos.x, y = pos.y - 0.1, z = pos.z}
    local is_walkable = ia_dunce.get_node_properties(minetest.get_node(below).name)
    if not is_walkable then return false end

    -- 3. Is there a physical obstacle in front of us that requires a jump?
    local ahead_pos = ia_dunce.get_relative_node_pos(self, 1, 0)
    local _, height = ia_dunce.get_node_properties(minetest.get_node(ahead_pos).name)
    
    -- 4. Is the head-space clear for the jump?
    local head_pos = ia_dunce.get_relative_node_pos(self, 1, 1)
    local head_clear = ia_dunce.is_buildable(head_pos)

    -- Result: Jump if target is high, obstacle is jumpable (<= 1.1), and head is clear
    return height <= 1.1 and head_clear
end

--- Logic for vertical leaps.
function ia_dunce.jump(self)
    -- Only jump if not already ascending/descending
    local v = self.object:get_velocity()
    if math.abs(v.y) < 0.1 then
        minetest.log('[Dunce] ' .. (self.mob_name or "Mob") .. ' jumping')
        ia_dunce.apply_vertical_impulse(self, 4.5) -- Adjusted for standard MTG jump
        return true
    end
    
    return false
end
