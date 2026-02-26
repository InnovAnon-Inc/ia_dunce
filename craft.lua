-- ia_dunce/craft.lua

--- Attempts to craft an item using standard recipes.
-- @param self The Dunce entity.
-- @param output_name The name of the item to craft.
-- @return boolean, string (Success status and message).
function ia_dunce.craft_item(self, output_name)
    minetest.log('ia_dunce.craft_item(' .. output_name .. ')')
    
    -- 1. Get recipe from engine
    local recipe = minetest.get_craft_recipe(output_name)
    if not recipe or not recipe.items then
        return false, "no_recipe"
    end

    -- 2. Verify we have the items (Inventory check)
    if not ia_dunce.has_required_items(self, ia_dunce.get_recipe_requirements(recipe.items)) then
        return false, "missing_ingredients"
    end

    -- 3. Execute: This is "magic" crafting (simulating a player using the 3x3 grid)
    -- We remove the ingredients and add the result.
    local inv = self.fake_player:get_inventory()
    
    -- Remove ingredients
    for _, item_name in pairs(recipe.items) do
        inv:remove_item("main", ItemStack(item_name))
    end
    
    -- Add result
    local result_stack = ItemStack(recipe.output)
    local leftover = inv:add_item("main", result_stack)
    
    if not leftover:is_empty() then
        -- Edge case: inventory filled up during craft (e.g., recursive containers)
        minetest.add_item(self.object:get_pos(), leftover)
    end

    -- Feedback
    ia_dunce.set_animation(self, "MINE", 20, false)
    minetest.sound_play("default_place_node", {pos = self.object:get_pos(), gain = 0.5})
    
    return true
end

--- Helper to turn a flat recipe list into a count table.
function ia_dunce.get_recipe_requirements(recipe_items)
    local reqs = {}
    for _, item in ipairs(recipe_items) do
        reqs[item] = (reqs[item] or 0) + 1
    end
    return reqs
end
