-- ia_dunce/fall.lua

--- Logic for detecting and reacting to falling.
function ia_dunce.fall(self)
	--minetest.log('ia_dunce.fall()')
    local v = self.object:get_velocity()
    if not v then return false end

    -- If descending faster than a certain threshold
    if v.y < -4.0 then
        -- Trigger "Panic" state or "FALL" animation
        ia_dunce.set_animation(self, 'FALL')
        
        -- Future-proofing: Look for water or hay blocks below to steer toward
        return true
    end

    return false
end
