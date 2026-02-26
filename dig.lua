-- ia_dunce/dig.lua

-- Helper: Handle the digging sounds
local function play_dig_sound(node_name, pos)
    local def = minetest.registered_nodes[node_name]
    if def and def.sounds and def.sounds.dug then
        minetest.sound_play(def.sounds.dug, {
            pos = pos,
            max_hear_distance = 10
        })
    end
end

--- Digs a node at the specified position.
-- @param pos The position to dig.
-- @return boolean, string (Success status and error message)
--function ia_dunce.dig(self, pos)
--	minetest.log('ia_dunce.dig()')
--    -- 1. Validate Protection
--    if minetest.is_protected(pos, self.object:get_player_name()) then
--        return false, "protected"
--    end
--
--    -- 2. Validate Distance
--    if not ia_dunce.is_within_reach(self, pos) then
--        return false, "too_far"
--    end
--
--    -- 3. Preparation: Stop and Look
--    self.object:set_velocity({x = 0, y = 0, z = 0})
--    local dir = vector.direction(self.object:get_pos(), pos)
--    self.object:set_look_horizontal(math.atan2(-dir.x, dir.z))
--    
--    -- 4. Animation (MINE is usually frame 160-200 in character.b3d)
--    --self.object:set_animation({x = 160, y = 200}, 30, 0, true)
--    ia_dunce.set_animation(self, 'MINE')
--
--    -- 5. The Actual Dig
--    -- Since 'self' is a fakelib/ia_fakeplayer, the engine treats it as a player!
--    local node = minetest.get_node(pos)
--    local tool = self.object:get_wielded_item()
--    
--    -- This handles: after_dig, protection, drops, and wear automatically.
--    local success = minetest.node_dig(pos, node, self)
--
--    if success then
--        play_dig_sound(node.name, pos)
--    end
--
--    -- 6. Cleanup
--    --self.object:set_animation({x = 0, y = 79}, 30, 0, true) -- STAND
--    ia_dunce.set_animation(self, 'STAND')
--    return success
--end
function ia_dunce.dig(self, pos)
    minetest.log('ia_dunce.dig()')
    -- Use the helper to check protection via the fake_player's name
    local name = self.fake_player:get_player_name()
    if minetest.is_protected(pos, name) then
        return false, "protected"
    end

    if not ia_dunce.is_within_reach(self, pos) then
        return false, "too_far"
    end

    ia_dunce.stop_and_look_at(self, pos)
    ia_dunce.set_animation(self, 'MINE')

    -- The engine needs the fake_player ObjectRef here, not the entity table
    local node = minetest.get_node(pos)
    local success = minetest.node_dig(pos, node, self.fake_player)

    if success then
        ia_dunce.play_node_sound(node.name, pos, "dug")
    end

    ia_dunce.set_animation(self, 'STAND')
    return success
end

--- Determines if the Dunce can potentially clear a path through this node.
-- @param self The Dunce entity.
-- @param node_name The name of the node (e.g., "default:stone").
-- @return boolean, number (can_dig, dig_time_estimate)
function ia_dunce.can_dig_node(self, node_name)
	--minetest.log('ia_dunce.can_dig_node()')
    local def = minetest.registered_nodes[node_name]
    if not def or not def.diggable then return false, 0 end

    -- Check if the node is protected
    -- (We don't want Duncans trying to dig through player-protected areas)
    -- This is a key edge case!

    -- TODO is switching wield items lib-level or app-level?

    -- Get the tool currently in the "main" hand
    local toolstack = self.object:get_wielded_item()
    local tool_caps = toolstack:get_tool_capabilities()

    -- Calculate dig time based on engine logic
    local stats = minetest.get_dig_params(def.groups, tool_caps)

    -- If diggable is false or time is too high (unbreakable), return false
    if not stats.diggable or stats.time > 10 then
        return false, 0
    end

    return true, stats.time
end
