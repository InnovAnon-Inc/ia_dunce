-- ia_dunce/till.lua

--- Low-level: Is the node capable of being turned into farmland?
function ia_dunce.is_tillable(pos)
    local node = minetest.get_node(pos)
    local is_soil = minetest.get_item_group(node.name, "soil") > 0
    local has_air_above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "air"
    return is_soil and has_air_above
end

--- High-level: Does the agent have the tool and is the node tillable?
function ia_dunce.can_till(self, pos)
    local has_hoe = ia_dunce.has_item(self, function(n) 
        return minetest.get_item_group(n, "hoe") > 0 
    end)
    
    if not has_hoe then return false end
    return ia_dunce.is_tillable(pos)
end

function ia_dunce.till(self, pos)
    minetest.log('ia_dunce.till()')
    local is_hoe = function(name) return minetest.get_item_group(name, "hoe") > 0 end
    local has_hoe = ia_dunce.wield_by_condition(self, is_hoe)
    
    if not has_hoe then
        return false, "no_hoe_found"
    end

    return ia_dunce.right_click(self, pos, false)
end
