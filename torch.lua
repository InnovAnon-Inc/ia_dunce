-- ia_dunce/torch.lua

--- Low-level: Can a torch be attached to this node/surface?
function ia_dunce.is_torch_placeable(pos)
    local node = minetest.get_node(pos)
    -- We use the helper from util.lua to see if the node is a solid/walkable block
    local props = ia_dunce.get_node_properties(node.name)
    return props == true
end

--- High-level: Does the agent have torches and a valid surface?
function ia_dunce.can_place_torch(self, pos)
    if not ia_dunce.has_torches(self) then return false end
    return ia_dunce.is_torch_placeable(pos)
end

function ia_dunce.place_torch(self, pos)
    minetest.log('ia_dunce.place_torch()')
    local is_torch = function(name) return minetest.get_item_group(name, "torch") > 0 end
    
    if ia_dunce.wield_by_condition(self, is_torch) then
        -- Sneak is true to avoid interacting with the node (e.g. opening a chest)
        return ia_dunce.right_click(self, pos, true)
    end
    
    return false, "no_torches"
end

function ia_dunce.has_torches(self)
    return ia_dunce.has_item(self, function(n) 
        return minetest.get_item_group(n, "torch") > 0 
    end)
end

function ia_dunce.is_too_dark(self)
    local pos = self.object:get_pos()
    if not pos then return false end
    -- Standard threshold for monster spawning and visibility
    return (minetest.get_node_light(pos) or 15) < 5
end
