-- ia_dunce/sensors.lua

-- TODO optionally search within chests
-- TODO need to be able to specify a sort callback (it's necessary to be able to sort by distance, but some jobs really need to preference the y-axis over the others)

--- Internal Helper: Finds and sorts objects based on a filter.
-- @param pos Center position
-- @param radius Search radius
-- @param filter_func function(object) returns boolean
-- @return table Sorted list of {object = obj, pos = p, distance = d}
local function get_sorted_objects(pos, radius, filter_func)
	--minetest.log('ia_dunce.get_sorted_objects()')
    local all_objects = minetest.get_objects_inside_radius(pos, radius)
    local filtered = {}

    for _, obj in ipairs(all_objects) do
        if not filter_func or filter_func(obj) then
            local obj_pos = obj:get_pos()
            table.insert(filtered, {
                object = obj,
                pos = obj_pos,
                distance = vector.distance(pos, obj_pos)
            })
        end
    end

    -- Sort by distance (ascending)
    table.sort(filtered, function(a, b)
        return a.distance < b.distance
    end)

    return filtered
end

--- Finds all players within range, matching an optional condition.
function ia_dunce.find_players(self, radius, condition)
	--minetest.log('ia_dunce.find_players()')
    local pos = self.object:get_pos()
    return get_sorted_objects(pos, radius, function(obj)
        if not obj:is_player() then return false end
        return not condition or condition(obj)
    end)
end

--- Finds all dropped items within range, matching an optional condition.
function ia_dunce.find_items(self, radius, condition)
	--minetest.log('ia_dunce.find_items()')
    --local pos = self:get_pos()
    local pos = self.object:get_pos()
    return get_sorted_objects(pos, radius, function(obj)
        local ent = obj:get_luaentity()
        if not ent or ent.name ~= "__builtin:item" then return false end
        
        -- Extract item data for the condition check
        local stack = ItemStack(ent.itemstring)
        return not condition or condition(stack, obj)
    end)
end

--- Finds all entities (mobs/enemies) within range.
-- @param condition function(object) to check for "enemy" status
function ia_dunce.find_entities(self, radius, condition)
	--minetest.log('ia_dunce.find_entities()')
    local pos = self.object:get_pos()
    local my_obj = self.object
    
    return get_sorted_objects(pos, radius, function(obj)
        if obj == my_obj then return false end -- Don't find yourself
        if obj:is_player() then return false end -- Players handled separately
        
        return not condition or condition(obj)
    end)
end



--- Finds the closest item that is actually reachable.
-- @param radius The search radius.
-- @param condition Optional extra filter.
-- @return table|nil The best target object data.
function ia_dunce.find_reachable_item(self, radius, condition)
	minetest.log('ia_dunce.find_reachable_item()')
    -- 1. Get all items sorted by distance (your existing code)
    local items = self:find_items(radius, condition)
    
    -- 2. Iterate through sorted list and return the first reachable one
    for _, item_data in ipairs(items) do
        if ia_dunce.is_target_accessible(item_data.pos) then
            -- Optional: Add a simple Line of Sight check here if you want 
            -- to prevent Dunces from "smelling" items through thick walls.
            -- if minetest.line_of_sight(self.object:get_pos(), item_data.pos) then
                return item_data
            -- end
        end
    end
    
    return nil
end

local function is_not_crowded(stack, obj) -- TODO expose convenience filters
    local pos = obj:get_pos()
    -- Reuse our occupation check from the previous step!
    -- We ignore the object itself, but check if ANYONE ELSE is standing there.
    return not ia_dunce.is_node_occupied(pos, obj)
end








function ia_dunce.get_sorted_nodes(pos, radius, node_names)
    local minp = vector.add(pos, -radius)
    local maxp = vector.add(pos, radius)
    local nodes = minetest.find_nodes_in_area(minp, maxp, node_names)

    local sorted = {}
    for _, p in ipairs(nodes) do
        table.insert(sorted, {
            pos = p,
            distance = vector.distance(pos, p)
        })
    end

    table.sort(sorted, function(a, b) return a.distance < b.distance end)
    return sorted
end
