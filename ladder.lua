-- ia_dunce/ladder.lua

--- Finds all ladders within a specific search area.
-- @param pos Center position.
-- @param radius Horizontal search radius.
-- @param vertical_range Vertical search range.
-- @return table List of ladder node positions.
function ia_dunce.find_nearby_ladders(pos, radius, vertical_range)
    local v_range = vertical_range or 2
    local minp = vector.add(pos, {x = -radius, y = -v_range, z = -radius})
    local maxp = vector.add(pos, {x = radius, y = v_range, z = radius})
    
    -- Search for nodes in the "ladder" group or specifically climbable
    return minetest.find_nodes_in_area(minp, maxp, {"group:ladder"})
end

--- Determines if a specific position contains a climbable node.
function ia_dunce.is_climbable(pos)
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
    return def and (def.climbable or minetest.get_item_group(node.name, "ladder") > 0)
end
