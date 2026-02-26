-- ia_dunce/punch.lua

--- Mimics a player punching an object or node.
-- @param self The fake player object
-- @param target The target (can be an ObjectRef or a position table)
-- @return boolean (Success status)
function ia_dunce.punch(self, target)
	minetest.log('ia_dunce.punch()')
    -- 1. Orientation
    local target_pos
    if type(target) == "table" and target.x then
        target_pos = target
    else
        target_pos = target:get_pos() -- target.object:get_pos() ?
    end
    
    local dir = vector.direction(self.object:get_pos(), target_pos)
    self.object:set_look_horizontal(math.atan2(-dir.x, dir.z))

    -- 2. Execute Punch
    if type(target) == "table" and target.x then
        -- Punching a node
        local node = minetest.get_node(target)
        local def = minetest.registered_nodes[node.name]
        
        -- Trigger the on_punch callback
        if def and def.on_punch then
            def.on_punch(target, node, self, nil)
        end
    else
        -- Punching an object (Mob, Player, etc.)
        -- This triggers the full engine damage system
        target:punch(self, 1.0, self.object:get_wielded_item():get_tool_capabilities(), dir)
    end

    -- 3. Feedback
    -- Punching is usually the first half of the mine animation
    --self.object:set_animation({x = 160, y = 180}, 30, 0, false)
    ia_dunce.set_animation(self, 'PUNCH', 30, false)
    
    -- Play a generic swing sound if the tool doesn't have one
    minetest.sound_play("player_punchplayer", {
        pos = target_pos,
        gain = 0.5,
        max_hear_distance = 5
    })

    return true
end
