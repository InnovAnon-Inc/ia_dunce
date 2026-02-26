-- ia_dunce/jump.lua

--- Logic for vertical leaps and climbing.
function ia_dunce.jump(self)
	minetest.log('ia_dunce.jump()')
    local pos = self.object:get_pos()
    if not pos then return false end

    local below = {x = pos.x, y = pos.y - 0.1, z = pos.z}
    local node_below = minetest.get_node(below)
    local v = self.object:get_velocity()

    -- Only jump if standing on a walkable surface and not already ascending/descending
    local is_walkable = ia_dunce.get_node_properties(node_below.name)
    if is_walkable and math.abs(v.y) < 0.1 then
        ia_dunce.apply_vertical_impulse(self, 5) -- Standard 1.1 block jump height
        return true
    end
    
    return false
end
