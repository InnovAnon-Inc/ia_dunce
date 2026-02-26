-- ia_dunce/lay.lua

function ia_dunce.lay(self)
	minetest.log('ia_dunce.lay()')
    -- Reduce collision box height for laying down
    self.object:set_properties({
        collisionbox = {-0.3, 0, -0.3, 0.3, 0.5, 0.3},
    })
    ia_dunce.set_animation(self, 'LAY')
end

--- Sets the mob into a laying posture.
-- @param self The entity object.
-- @param state boolean: true to lay down, false to stand up.
function ia_dunce.set_lay_posture(self, state)
	minetest.log('ia_dunce.set_lay_posture()')
    if state then
        -- Lower collision box for laying down
        self.object:set_properties({
            collisionbox = {-0.3, 0, -0.3, 0.3, 0.5, 0.3},
            physical = false -- Usually disabled while in a bed to prevent "shaking"
        })
        ia_dunce.set_animation(self, 'LAY')
        self.data.is_laying = true
    else
        -- Restore standard collision box (adjust values to your default mob size)
        self.object:set_properties({
            collisionbox = {-0.3, 0, -0.3, 0.3, 1.7, 0.3},
            physical = true
        })
        ia_dunce.set_animation(self, 'STAND')
        self.data.is_laying = false
    end
end
