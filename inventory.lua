-- ia_dunce/inventory.lua

local function get_inv(self)
    -- Crucial fix: inventory is hosted on the fake_player object
    return self.fake_player:get_inventory()
end
--- Internal Helper: Retrieves the inventory object for the fake player.
--local function get_inv(self)
--    return self:get_inventory()
--end

--- Attempts to pick up a specific item entity (dropped item).
-- @param self The fake player object.
-- @param item_obj The ObjectRef of the dropped item.
-- @return boolean, string (Success status and reason).
function ia_dunce.pickup_item(self, item_obj)
	minetest.log('ia_dunce.pickup_item()')
    local entity = item_obj:get_luaentity()
    if not entity or entity.name ~= "__builtin:item" then
        return false, "not_an_item"
    end

    -- Validate distance (Standard pickup range is ~2.0)
    local dist = vector.distance(self.object:get_pos(), item_obj:get_pos())
    if dist > 2.0 then
        return false, "too_far"
    end

    local inv = get_inv(self)
    local stack = ItemStack(entity.itemstring)
    local leftover = inv:add_item("main", stack)

    -- Handle stack updates or removal
    if leftover:get_count() == stack:get_count() then
        return false, "inventory_full"
    elseif leftover:is_empty() then
        item_obj:remove()
    else
        entity.itemstring = leftover:to_string()
    end

    minetest.sound_play("item_pickup", {pos = self.object:get_pos(), gain = 0.3})
    return true
end

--- Scans and picks up items matching a condition within range.
-- @param self The fake player object.
-- @param radius Search radius.
-- @param condition Optional function(itemstack).
function ia_dunce.pickup_nearby(self, radius, condition)
	minetest.log('ia_dance.pickup_nearby()')
    local items = self:find_items(radius, condition) -- Calls the sensor helper
    local any_picked_up = false

    for _, item_data in ipairs(items) do
        if ia_dunce.pickup_item(self, item_data.object) then
            any_picked_up = true
        end
    end

    return any_picked_up
end

--- Swaps current wielded item with an item from 'main' inventory.
-- @param self The fake player object.
-- @param condition function(name) or string (itemname).
-- @return boolean (Success status).
function ia_dunce.wield_by_condition(self, condition)
	minetest.log('ia_dunce.wield_by_condition()')
    local inv = get_inv(self)
    local main_list = inv:get_list("main")
    
    local predicate = type(condition) == "string" 
        and function(name) return name == condition end 
        or condition

    for i, stack in ipairs(main_list) do
        if not stack:is_empty() and predicate(stack:get_name()) then
            -- Use official methods to swap safely
            local current_hand_stack = self.object:get_wielded_item()
            self.object:set_wielded_item(stack)
            inv:set_stack("main", i, current_hand_stack)
            return true
        end
    end
    return false
end

--- Checks if the Dunce is carrying a specific item (wielded or in main).
-- @param self The fake player object.
-- @param condition function(name) or string.
-- @return boolean.
function ia_dunce.has_item(self, condition)
	minetest.log('ia_dunce.has_item()')
    local wield_name = self.object:get_wielded_item():get_name()
    local predicate = type(condition) == "string" 
        and function(n) return n == condition end 
        or condition

    if predicate(wield_name) then return true end

    local inv = get_inv(self)
    for _, stack in ipairs(inv:get_list("main")) do
        if not stack:is_empty() and predicate(stack:get_name()) then
            return true
        end
    end
    
    return false
end

--- Basic wrapper to add an item to the Dunce's main bags.
-- @return ItemStack (Leftovers).
function ia_dunce.add_to_inventory(self, stack)
	minetest.log('ia_dunce.add_to_inventory()')
    return get_inv(self):add_item("main", stack)
end

--- Checks if the Dunce has room for at least one of this item.
function ia_dunce.has_room_for(self, item_name)
	minetest.log('ia_dunce.has_room_for()')
    --local inv = self.object:get_inventory()
    local inv = self.fake_player:get_inventory()
    assert(inv ~= nil)
    local stack = ItemStack(item_name)
    -- check if it can be added to the 'main' list
    return inv:room_for_item("main", stack)
end













--- Internal Helper: Retrieves the inventory object for the fake player.

--- Returns the total count of a specific item in the Dunce's inventory.
-- @param self The Dunce entity.
-- @param item_name The name of the item to count.
-- @return number Total count.
function ia_dunce.get_item_count(self, item_name)
	minetest.log('ia_dunce.get_item_count()')
    local inv = get_inv(self)
    local count = 0
    local main_list = inv:get_list("main")

    if not main_list then return 0 end

    for _, stack in ipairs(main_list) do
        if not stack:is_empty() and stack:get_name() == item_name then
            count = count + stack:get_count()
        end
    end

    -- Also check the wielded item slot
    local wielded = self.object:get_wielded_item()
    if wielded:get_name() == item_name then
        count = count + wielded:get_count()
    end

    return count
end

----- Checks if the Dunce has room for at least one of this item.
--function ia_dunce.has_room_for(self, item_name)
--    local inv = get_inv(self)
--    local stack = ItemStack(item_name)
--    return inv:room_for_item("main", stack)
--end

--- Checks if all numeric requirements are met.
-- @param requirements Table like { ["default:stone"] = 8 }
function ia_dunce.has_required_items(self, requirements)
	minetest.log('ia_dunce.has_required_items()')
    for item_name, amount in pairs(requirements) do
        if type(amount) == "number" then
            if ia_dunce.get_item_count(self, item_name) < amount then
                return false
            end
        end
    end
    return true
end

--- Specifically handles moving armor from inventory to the fake player's slots.
-- @param self The fake player object.
-- @param condition Optional filter (defaults to all armor).
-- @return boolean (Success).
function ia_dunce.auto_equip_armor(self, condition)
    minetest.log('ia_dunce.auto_equip_armor()')
    if not armor then return false end

    local inv = get_inv(self)
    local main_list = inv:get_list("main")

    for i, stack in ipairs(main_list) do
        local name = stack:get_name()
        if not stack:is_empty() and minetest.get_item_group(name, "armor") > 0 then
            -- Use the armor mod API
            armor:equip(self.fake_player, stack)
            return true
        end
    end
    return false
end
