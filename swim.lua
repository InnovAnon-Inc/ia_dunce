-- ia_dunce/swim.lua

--- Logic for aquatic movement and floating.
function ia_dunce.swim(self)
	--minetest.log('ia_dunce.swim()')
    local pos = self.object:get_pos()
    if not pos then return false end

    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]

    -- Check if the node is a liquid (water, lava, etc.)
    if def and (def.drawtype == "liquid" or def.drawtype == "flowingliquid") then
        -- Apply a gentle upward force to simulate swimming/treading water
        ia_dunce.apply_vertical_impulse(self, 2)
        return true
    end
    
    return false
end
