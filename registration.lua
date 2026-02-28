-- ia_dunce/registration.lua

function ia_dunce.register_dunce_entity(name, definition)
    minetest.log('action', '[ia_dunce] Registering Dunce: ' .. name)

    local final_def           = table.copy(definition)
    local current_on_activate = definition.on_activate

    final_def.on_activate = function(self, staticdata, dtime_s)
        -- If ia_pathfinding didn't already call this, call it now
        -- We check for a "dunce_init" flag to prevent double-init
        if not self._dunce_initialized then
            ia_dunce.init_instance(self)
            self._dunce_initialized = true
        end
        assert(self:is_player() == true)

        if current_on_activate then
            current_on_activate(self, staticdata, dtime_s)
        end
        assert(self:is_player() == true)
    end

    -- Pass down to the physical engine
    ia_humanoid.register_humanoid_entity(name, final_def)
end
