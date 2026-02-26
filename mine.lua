-- ia_dunce/mine.lua

--- Low-level: Is the node at this position of a type that can be mined?
function ia_dunce.is_mineable(pos)
    local node = minetest.get_node(pos)
    -- Stone and ores belong to the 'cracky' group
    return minetest.get_item_group(node.name, "cracky") > 0
end

--- High-level: Is the mob equipped/ready to mine this stone?
function ia_dunce.can_mine(self, pos)
    if not ia_dunce.is_mineable(pos) then return false end

    -- Check if we have a tool that makes this mineable in a reasonable time
    local node = minetest.get_node(pos)
    local can_physically_dig, time = ia_dunce.can_dig_node(self, node.name)
    local has_pick = ia_dunce.has_item(self, function(n)
        return minetest.get_item_group(n, "pickaxe") > 0
    end)

    -- Mining usually requires a pickaxe unless the node is very soft (< 2s)
    return can_physically_dig and (has_pick or time < 2.0)
end

function ia_dunce.mine(self, pos)
    local is_pick = function(n) return minetest.get_item_group(n, "pickaxe") > 0 end
    ia_dunce.wield_by_condition(self, is_pick)
    return ia_dunce.left_click(self, pos, true)
end
