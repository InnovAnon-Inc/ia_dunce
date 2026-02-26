-- ia_dunce/registration.lua

----- Registers a Dunce entity by wrapping the humanoid registration.
---- This injects the worker logic (ia_dunce) into the humanoid body.
---- @param name The entity name (e.g., "my_mod:villager")
---- @param definition The entity definition table.
--function ia_dunce.register_dunce_entity(name, definition)
--    -- 1. Capture the user's original on_activate
--    local user_on_activate = definition.on_activate
--
--    -- 2. Create the injected on_activate
--    definition.on_activate = function(self, staticdata, dtime_s)
--        -- Initialize the ia_dunce worker logic (our methods)
--        ia_dunce.init_instance(self)
--        
--        -- Run the original activate logic if it exists
--        if user_on_activate then
--            user_on_activate(self, staticdata, dtime_s)
--        end
--    end
--
--    -- 3. Delegate to ia_humanoid for the physical/visual setup
--    ia_humanoid.register_humanoid_entity(name, definition)
--    
--    minetest.log("action", "[ia_dunce] Registered worker entity: " .. name)
--end
--
----function ia_dunce.register_dunce_entity(name, definition)
----    -- Capture the user's original on_activate (the one in your mob definition)
----    local user_on_activate = definition.on_activate
----
----    -- We redefine on_activate to control the sequence
----    definition.on_activate = function(self, staticdata, dtime_s)
----        -- 1. ia_humanoid's internal hook will run first because it's
----        -- injected into the final_def by register_humanoid_entity.
----        -- BUT, since we want to be safe, we let ia_humanoid do its thing.
----
----        -- 2. Run the humanoid registration logic
----        -- (This ensures self.fake_player is created and get_player_name exists)
----
----        -- 3. Initialize our dunce methods
----        ia_dunce.init_instance(self)
----
----        -- 4. Finally, run the user's specific mob logic (like starting timers)
----        if user_on_activate then
----            user_on_activate(self, staticdata, dtime_s)
----        end
----    end
----
----    -- Delegate the actual registration to the humanoid layer
----    ia_humanoid.register_humanoid_entity(name, definition)
----end

function ia_dunce.register_dunce_entity(name, definition)
	minetest.log('ia_dunce.register_dunce_entity()')
    local user_on_activate = definition.on_activate
    local user_on_step = definition.on_step

    -- Injected On Step: This is the "Brain Tick"
    definition.on_step = function(self, dtime)
        -- 1. Process Pathfinding Coroutines (The "Thinking" phase)
        --ia_dunce.process_pathfinding(self)

        -- 2. Process Appliance/Task Coroutines (The "Working" phase)
        -- We can use the same logic for your appliance.lua yields!

        -- 3. Run the user's logic (Scavenging, etc.)
        if user_on_step then
            user_on_step(self, dtime)
        end
    end

    definition.on_activate = function(self, staticdata, dtime_s)
        ia_dunce.init_instance(self)
        if user_on_activate then
            user_on_activate(self, staticdata, dtime_s)
        end
    end

    ia_humanoid.register_humanoid_entity(name, definition)

    minetest.log("action", "[ia_dunce] Registered worker entity: " .. name)
end
