-- ia_dunce/place.lua

----- Places the currently wielded item at the given position.
---- @param self The fake player object
---- @param pos The position to place the node
---- @return boolean, string (Success status and error message)
--function ia_dunce.place(self, pos)
--	minetest.log('ia_dunce.place()')
--	-- 1. Validate Target
--	if not ia_dunce.is_buildable(pos) then
--		return false, "blocked"
--	end
--
--	-- 2. Validate Protection
--	if minetest.is_protected(pos, self.object:get_player_name()) then
--		return false, "protected"
--	end
--
--	-- 3. Prepare State (Turn to face the position)
--	local dir = vector.direction(self.object:get_pos(), pos)
--	self.object:set_look_horizontal(math.atan2(-dir.x, dir.z))
--	
--	-- 4. Get Item
--	local stack = self.object:get_wielded_item()
--	if stack:is_empty() then
--		return false, "no_item"
--	end
--
--	-- 5. The Actual Place
--	-- We use minetest.item_place to trigger all the standard logic.
--	-- It returns the remaining stack.
--	local pointed_thing = ia_dunce.get_pointed_thing(pos)
--
----	if not is_buildable(pointed_thing.above) then
----        -- If we can't place it where we pointed, try the original pos 
----        -- (useful for tall grass/flowers)
----        	pointed_thing.above = pos
----    	end
--
----	local new_stack = minetest.item_place(stack, self, pointed_thing)
--	-- Inside ia_dunce.place (logic update)
--local before_node = minetest.get_node(pos).name
--local new_stack = minetest.item_place(stack, self.fake_player, pointed_thing)
--local after_node = minetest.get_node(pos).name
--
---- If the node didn't change and the stack size is the same, it failed.
--if before_node == after_node and new_stack:get_count() == stack:get_count() then
--    return false, "blocked_by_engine"
--end
--
--	-- 6. Check for success (did the stack size decrease?)
--	local success = new_stack:get_count() < stack:get_count()
--	
--	-- Note: Some items (like buckets) might change name instead of count.
--	if not success and new_stack:get_name() ~= stack:get_name() then
--		success = true
--	end
--
--	if success then
--		-- Update inventory with the result (taken item or transformed item)
--		self.object:set_wielded_item(new_stack)
--		
--		-- Play place sound (if not already played by the engine)
--		local def = minetest.registered_items[stack:get_name()]
--		if def and def.sounds and def.sounds.place then
--			minetest.sound_play(def.sounds.place, {pos = pos, gain = 0.5})
--		end
--
--		-- Trigger animation
--		--self.object:set_animation({x = 160, y = 200}, 30, 0, true) -- MINE/PLACE
--		-- A quick "use" animation that doesn't repeat
--		ia_dunce.set_animation(self, "MINE", 40, false)
--	end
--
--	return success
--end
--
--
--
--
--
--



-- ia_dunce/place.lua

--- Generic wrapper for placing a block or using an item (like a hoe).
-- @param self The Dunce entity.
-- @param pos The position to place 'against' or 'on'.
-- @return boolean (Success).
function ia_dunce.place(self, pos)
    minetest.log('ia_dunce.place()')
    local stack = self.object:get_wielded_item()
    if stack:is_empty() then return false end

    -- Determine where we are placing (usually 'above' the node we clicked)
    -- This follows standard Minetest 'under' and 'above' logic.
    local pointed_thing = {
        type = "node",
        under = pos,
        above = vector.add(pos, {x = 0, y = 1, z = 0})
    }

    -- 1. Check protection using fake_player identity
    if minetest.is_protected(pointed_thing.above, self.fake_player:get_player_name()) then
        return false, "protected"
    end

    -- 2. Call the item's placement/usage logic
    -- This triggers hoes, torches, and block placement.
    local leftover, success = minetest.item_place(stack, self.fake_player, pointed_thing)

    if success then
        self.object:set_wielded_item(leftover)

        -- Feedback
        local node_name = stack:get_name()
        ia_dunce.play_node_sound(node_name, pointed_thing.above, "place")
        ia_dunce.set_animation(self, "MINE", 40, false)
    end

    return success
end
