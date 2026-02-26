-- ia_dunce/dig.lua

--- Low-level: Can this node be dug at all? (ignoring current inventory)
function ia_dunce.is_diggable(pos)
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
    return def and def.diggable ~= false
end

--- High-level: Is the mob equipped to dig this specific crumbly node efficiently?
function ia_dunce.can_dig(self, pos)
    local node = minetest.get_node(pos)
    local can_physically_dig, time = ia_dunce.can_dig_node(self, node.name) -- from leftclick.lua
    
    -- Digging usually implies 'crumbly' group (dirt/sand)
    local is_crumbly = minetest.get_item_group(node.name, "crumbly") > 0
    local has_shovel = ia_dunce.has_item(self, function(n) 
        return minetest.get_item_group(n, "shovel") > 0 
    end)

    return can_physically_dig and is_crumbly and (has_shovel or time < 1.0)
end

function ia_dunce.dig(self, pos, keep) 
    return ia_dunce.left_click(self, pos, keep) 
end
