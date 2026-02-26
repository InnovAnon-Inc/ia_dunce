-- ia_dunce/leftclick.lua

------ Helper: Handle the digging sounds
----local function play_dig_sound(node_name, pos)
----    local def = minetest.registered_nodes[node_name]
----    if def and def.sounds and def.sounds.dug then
----        minetest.sound_play(def.sounds.dug, {
----            pos = pos,
----            max_hear_distance = 10
----        })
----    end
----end
----
------- Digs a node at the specified position.
------ @param pos The position to dig.
------ @return boolean, string (Success status and error message)
------function ia_dunce.dig(self, pos)
------	minetest.log('ia_dunce.dig()')
------    -- 1. Validate Protection
------    if minetest.is_protected(pos, self.object:get_player_name()) then
------        return false, "protected"
------    end
------
------    -- 2. Validate Distance
------    if not ia_dunce.is_within_reach(self, pos) then
------        return false, "too_far"
------    end
------
------    -- 3. Preparation: Stop and Look
------    self.object:set_velocity({x = 0, y = 0, z = 0})
------    local dir = vector.direction(self.object:get_pos(), pos)
------    self.object:set_look_horizontal(math.atan2(-dir.x, dir.z))
------    
------    -- 4. Animation (MINE is usually frame 160-200 in character.b3d)
------    --self.object:set_animation({x = 160, y = 200}, 30, 0, true)
------    ia_dunce.set_animation(self, 'MINE')
------
------    -- 5. The Actual Dig
------    -- Since 'self' is a fakelib/ia_fakeplayer, the engine treats it as a player!
------    local node = minetest.get_node(pos)
------    local tool = self.object:get_wielded_item()
------    
------    -- This handles: after_dig, protection, drops, and wear automatically.
------    local success = minetest.node_dig(pos, node, self)
------
------    if success then
------        play_dig_sound(node.name, pos)
------    end
------
------    -- 6. Cleanup
------    --self.object:set_animation({x = 0, y = 79}, 30, 0, true) -- STAND
------    ia_dunce.set_animation(self, 'STAND')
------    return success
------end
----function ia_dunce.dig(self, pos)
----    minetest.log('ia_dunce.dig()')
----    -- Use the helper to check protection via the fake_player's name
----    local name = self.fake_player:get_player_name()
----    if minetest.is_protected(pos, name) then
----        return false, "protected"
----    end
----
----    if not ia_dunce.is_within_reach(self, pos) then
----        return false, "too_far"
----    end
----
----    ia_dunce.stop_and_look_at(self, pos)
----    ia_dunce.set_animation(self, 'MINE')
----
----    -- The engine needs the fake_player ObjectRef here, not the entity table
----    local node = minetest.get_node(pos)
----    local success = minetest.node_dig(pos, node, self.fake_player)
----
----    if success then
----        ia_dunce.play_node_sound(node.name, pos, "dug")
----    end
----
----    ia_dunce.set_animation(self, 'STAND')
----    return success
----end
----
------- Determines if the Dunce can potentially clear a path through this node.
------ @param self The Dunce entity.
------ @param node_name The name of the node (e.g., "default:stone").
------ @return boolean, number (can_dig, dig_time_estimate)
----function ia_dunce.can_dig_node(self, node_name)
----	--minetest.log('ia_dunce.can_dig_node()')
----    local def = minetest.registered_nodes[node_name]
----    if not def or not def.diggable then return false, 0 end
----
----    -- Check if the node is protected
----    -- (We don't want Duncans trying to dig through player-protected areas)
----    -- This is a key edge case!
----
----    -- TODO is switching wield items lib-level or app-level?
----
----    -- Get the tool currently in the "main" hand
----    local toolstack = self.object:get_wielded_item()
----    local tool_caps = toolstack:get_tool_capabilities()
----
----    -- Calculate dig time based on engine logic
----    local stats = minetest.get_dig_params(def.groups, tool_caps)
----
----    -- If diggable is false or time is too high (unbreakable), return false
----    if not stats.diggable or stats.time > 10 then
----        return false, 0
----    end
----
----    return true, stats.time
----end
--
--
--
--
--
--
---- ia_dunce/leftclick.lua
--
----- Internal helper to find the best tool for a job.
--local function get_best_tool_for_node(self, node_name)
--    local def = minetest.registered_nodes[node_name]
--    if not def or not def.groups then return nil end
--
--    local inv = self.fake_player:get_inventory()
--    local main_list = inv:get_list("main")
--    local best_tool_index = nil
--    local best_time = 999
--
--    for i, stack in ipairs(main_list) do
--        local caps = stack:get_tool_capabilities()
--        if caps then
--            local stats = minetest.get_dig_params(def.groups, caps)
--            if stats.diggable and stats.time < best_time then
--                best_time = stats.time
--                best_tool_index = i
--            end
--        end
--    end
--
--    return best_tool_index, best_time
--end
--
----- Primary left-click action. Handles digging and hitting.
---- @param pos_or_obj Vector3 or ObjectRef.
---- @param keep_tool boolean (If true, won't swap back to hand after).
--function ia_dunce.left_click(self, pos_or_obj, keep_tool)
--    minetest.log('ia_dunce.left_click()')
--    local is_object = type(pos_or_obj) == "userdata" and pos_or_obj.get_pos
--    local pos = is_object and pos_or_obj:get_pos() or pos_or_obj
--
--    if not ia_dunce.is_within_reach(self, pos) then return false, "too_far" end
--
--    -- 1. Setup Focus
--    ia_dunce.stop_and_look_at(self, pos)
--    ia_dunce.set_animation(self, 'MINE')
--
--    -- 2. Tool Management
--    local original_wield = self.object:get_wielded_item()
--    if not is_object then
--        local node_name = minetest.get_node(pos).name
--        local tool_idx, time = get_best_tool_for_node(self, node_name)
--
--        -- If we found a better tool in inventory, swap to it
--        if tool_idx then
--            local inv = self.fake_player:get_inventory()
--            local tool_stack = inv:get_stack("main", tool_idx)
--            self.object:set_wielded_item(tool_stack)
--            inv:set_stack("main", tool_idx, original_wield)
--        end
--    end
--
--    -- 3. Execution
--    local success = false
--    if is_object then
--        pos_or_obj:punch(self.fake_player, 1.0, self.object:get_wielded_item():get_tool_capabilities())
--        success = true
--    else
--        local node = minetest.get_node(pos)
--        success = minetest.node_dig(pos, node, self.fake_player)
--        if success then ia_dunce.play_node_sound(node.name, pos, "dug") end
--    end
--
--    -- 4. Cleanup/Persistence
--    if not keep_tool and not is_object then
--        -- Swap back to original item (usually hand/empty)
--        local current_tool = self.object:get_wielded_item()
--        self.object:set_wielded_item(original_wield)
--
--        -- Put tool back in its slot
--        local inv = self.fake_player:get_inventory()
--        for i, stack in ipairs(inv:get_list("main")) do
--            if stack:is_empty() then
--                inv:set_stack("main", i, current_tool)
--                break
--            end
--        end
--    end
--
--    ia_dunce.set_animation(self, 'STAND')
--    return success
--end
--
---- Aliases for your requested downstream files
----function ia_dunce.dig(self, pos, keep) return ia_dunce.left_click(self, pos, keep) end
----function ia_dunce.punch(self, obj) return ia_dunce.left_click(self, obj, true) end

-- ia_dunce/leftclick.lua

--- Internal helper to find the best tool for a job.
local function get_best_tool_for_node(self, node_name)
    local def = minetest.registered_nodes[node_name]
    if not def or not def.groups then return nil end

    local inv = self.fake_player:get_inventory()
    local main_list = inv:get_list("main")
    local best_tool_index = nil
    local best_time = 999

    -- Check current wielded item first
    local wielded = self.object:get_wielded_item()
    local w_caps = wielded:get_tool_capabilities()
    if w_caps then
        local w_stats = minetest.get_dig_params(def.groups, w_caps)
        if w_stats.diggable then best_time = w_stats.time end
    end

    -- Scan inventory for a better match
    for i, stack in ipairs(main_list) do
        local caps = stack:get_tool_capabilities()
        if caps then
            local stats = minetest.get_dig_params(def.groups, caps)
            if stats.diggable and stats.time < best_time then
                best_time = stats.time
                best_tool_index = i
            end
        end
    end

    return best_tool_index, best_time
end

--- Determines if the Dunce can potentially clear a path through this node.
-- @return boolean, number (can_dig, dig_time_estimate)
function ia_dunce.can_dig_node(self, node_name)
    local def = minetest.registered_nodes[node_name]
    if not def or not def.diggable then return false, 0 end

    -- Check best tool in inventory to get an accurate time estimate
    local _, time = get_best_tool_for_node(self, node_name)

    -- If no tool makes it diggable under 10s, consider it unbreakable
    if time > 10 then return false, time end

    return true, time
end

--- Primary left-click action. Handles digging and hitting.
function ia_dunce.left_click(self, pos_or_obj, keep_tool)
    minetest.log('ia_dunce.left_click()')
    local is_object = type(pos_or_obj) == "userdata" and pos_or_obj.get_pos
    local pos = is_object and pos_or_obj:get_pos() or pos_or_obj

    if not ia_dunce.is_within_reach(self, pos) then return false, "too_far" end

    ia_dunce.stop_and_look_at(self, pos)
    ia_dunce.set_animation(self, 'MINE')

    local original_wield = self.object:get_wielded_item()
    if not is_object then
        local node_name = minetest.get_node(pos).name
        local tool_idx = get_best_tool_for_node(self, node_name)

        if tool_idx then
            local inv = self.fake_player:get_inventory()
            local tool_stack = inv:get_stack("main", tool_idx)
            self.object:set_wielded_item(tool_stack)
            inv:set_stack("main", tool_idx, original_wield)
        end
    end

    local success = false
    if is_object then
        pos_or_obj:punch(self.fake_player, 1.0, self.object:get_wielded_item():get_tool_capabilities())
        success = true
    else
        local node = minetest.get_node(pos)
        success = minetest.node_dig(pos, node, self.fake_player)
        if success then ia_dunce.play_node_sound(node.name, pos, "dug") end
    end

    if not keep_tool and not is_object then
        local current_tool = self.object:get_wielded_item()
        self.object:set_wielded_item(original_wield)
        local inv = self.fake_player:get_inventory()
        for i, stack in ipairs(inv:get_list("main")) do
            if stack:is_empty() then
                inv:set_stack("main", i, current_tool)
                break
            end
        end
    end

    ia_dunce.set_animation(self, 'STAND')
    return success
end
