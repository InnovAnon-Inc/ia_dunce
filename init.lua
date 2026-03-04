-- ia_dunce/init.lua

assert(minetest.get_modpath('ia_util'))
assert(ia_util ~= nil)
local modname                    = minetest.get_current_modname() or "ia_dunce"
local storage                    = minetest.get_mod_storage()
ia_dunce                         = {}
--local files = {
--    "animation",
--    "appliance",
--    "armor",
--    "bed",
--    "boat",
--    "book",
--    "bucket",
--    "bug_net",
--    "chest",
--    "climb",
--    "craft",
--    "cramped",
--    "dig",
--    "doors",
--    "fall",
--    "fly",
--    "food",
--    "furnace",
--    "jump",
--    "interact",
--    "inventory",
--    "is_at",
--    "is_line_of_sight_clear",
--    "is_stuck",
--    "ladder",
--    "leftclick",
--    "lay",
--    "move_vertically",
--    --"movement",
--    --"pathfinding",
--    "place",
--    "punch",
--    "recipes",
--    "registration",
--    "rightclick",
--    --"scavenge",
--    "sensors",
--    "sneak",
--    "steal",
--    "stop",
--    "storage",
--    "swim",
--    "tod",
--    "trapdoors",
--    "use",
--    "util",
--    "walk",
--}
local modpath, S                 = ia_util.loadmod(modname)
local log                        = ia_util.get_logger(modname)
local assert                     = ia_util.get_assert(modname)

----- Constructor for a new Dunce instance.
---- Wraps an ia_fakelib object with our village-worker logic.
---- @param self_obj The base entity object (from ia_fakelib)
--function ia_dunce.init_instance(self_obj)
--    -- This allows us to call ia_dunce methods directly on the entity
--    -- without overwriting the base ia_fakelib methods.
--    for name, func in pairs(ia_dunce) do
--        if name ~= "init_instance" then
--            self_obj[name] = func
--        end
--    end
--    
--    minetest.log("action", "[ia_dunce] Initialized worker logic for: " .. (self_obj:get_player_name() or "unknown"))
--end
function ia_dunce.init_instance(self_obj)
	--minetest.log('ia_dunce.init_instance()')
    -- Inject methods
    for name, func in pairs(ia_dunce) do
        if name ~= "init_instance" and name ~= "register_dunce_entity" then
            self_obj[name] = func
        end
    end
    
    -- Safe logging with a fallback
    local name = "Unknown"
    if self_obj.get_player_name then
        name = self_obj:get_player_name()
    elseif self_obj.fake_player and self_obj.fake_player.get_player_name then
        name = self_obj.fake_player:get_player_name()
    end

    self_obj._last_pos = vector.new(0,0,0)
    self_obj._stagnant_ticks = 0

    minetest.log("action", "[ia_dunce] Worker logic attached to: " .. name)
end

minetest.log("action", "[ia_dunce] API Loaded Successfully.")
