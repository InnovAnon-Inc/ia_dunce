-- ia_dunce/armor.lua
-- NOTE musut handle boots, pants, shirt, helmet, shield and whatever the 6th slot is for

--- Low-level: Is this item name actually armor?
-- @param item_name The name of the item.
-- @param armor_type Optional specific group like "torso", "legs", "head", "feet".
function ia_dunce.is_armorable(item_name, armor_type)
    local is_armor = minetest.get_item_group(item_name, "armor") > 0
    if armor_type then
        return is_armor and minetest.get_item_group(item_name, armor_type) > 0
    end
    return is_armor
end

--- Mid-level: Is the agent already wearing armor of this type?
function ia_dunce.is_armored(self, armor_type)
    -- This depends on the 'armor' mod being present
    if not armor or not armor.get_armor_inventory then return false end
    
    local armor_inv = armor:get_armor_inventory(self.fake_player)
    local list = armor_inv:get_list("armor")
    
    for _, stack in ipairs(list) do
        if not stack:is_empty() and ia_dunce.is_armorable(stack:get_name(), armor_type) then
            return true
        end
    end
    return false
end

--- Mid-level: Does the agent have suitable armor in their inventory?
function ia_dunce.can_armor(self, armor_type)
    return ia_dunce.has_item(self, function(n) 
        return ia_dunce.is_armorable(n, armor_type) 
    end)
end

--- High-level: Could the agent obtain armor via trivial crafting?
function ia_dunce.could_armor(self, armor_type)
    if ia_dunce.can_armor(self, armor_type) then return true end

    -- Check for common trivial armor recipes (e.g., wood/steel/leather)
    -- Note: We check for a generic chestplate if no type is specified
    local target = armor_type == "head" and "3d_armor:helmet_wood" 
                or armor_type == "torso" and "3d_armor:chestplate_wood"
                or "3d_armor:chestplate_wood"

    return ia_dunce.can_obtain_item(self, target)
end

--- Level 1: Atomic Action
-- Direct call to armor mod API to equip a stack.
function ia_dunce.equip_armor_stack(self, stack)
    minetest.log('ia_dunce.equip_armor_stack()')
    if armor and armor.equip then
        armor:equip(self.fake_player, stack)
        return true
    end
    return false, "armor_mod_missing"
end

--- Level 2: Preparation + Action
-- Finds armor in inventory and puts it on.
function ia_dunce.search_and_equip_armor(self, armor_type)
    minetest.log('ia_dunce.search_and_equip_armor()')
    local inv = self.fake_player:get_inventory()
    local main_list = inv:get_list("main")

    for i, stack in ipairs(main_list) do
        if not stack:is_empty() and ia_dunce.is_armorable(stack:get_name(), armor_type) then
            local success = ia_dunce.equip_armor_stack(self, stack)
            if success then
                inv:set_stack("main", i, ItemStack("")) -- Remove from main inv
                return true
            end
        end
    end
    return false, "no_armor_found_in_inventory"
end

--- Level 3: Provisioning + Preparation + Action
-- Crafts armor if missing, then equips it.
function ia_dunce.craft_and_equip_armor(self, armor_type)
    minetest.log('ia_dunce.craft_and_equip_armor()')
    
    if not ia_dunce.can_armor(self, armor_type) then
        local target = armor_type == "torso" and "3d_armor:chestplate_wood" or "3d_armor:helmet_wood"
        if ia_dunce.can_obtain_item(self, target) then
            ia_dunce.craft_item(self, target)
        end
    end

    return ia_dunce.search_and_equip_armor(self, armor_type)
end
