-- ia_dunce/chop.lua

--- Low-level: Is the node at this position wood-like/choppable?
function ia_dunce.is_choppable(pos)
    local node = minetest.get_node(pos)
    return minetest.get_item_group(node.name, "choppy") > 0
end

--- High-level: Can we efficiently chop this wood?
function ia_dunce.can_chop(self, pos)
    if not ia_dunce.is_choppable(pos) then return false end

    local has_axe = ia_dunce.has_item(self, function(n)
        return minetest.get_item_group(n, "axe") > 0
    end)

    local node = minetest.get_node(pos)
    local can_physically_dig, time = ia_dunce.can_dig_node(self, node.name)
    return can_physically_dig and (has_axe or time < 1.5)
end

function ia_dunce.chop(self, pos)
    local is_axe = function(n) return minetest.get_item_group(n, "axe") > 0 end
    ia_dunce.wield_by_condition(self, is_axe)
    return ia_dunce.left_click(self, pos, true)
end
