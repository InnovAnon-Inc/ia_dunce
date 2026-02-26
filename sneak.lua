-- ia_dunce/sneak.lua

function ia_dunce.sneak(self, active)
	minetest.log('ia_dunce.sneak()')
    if active then
        -- Slow down speed and lower eye level/animation
        self._is_sneaking = true
        ia_dunce.set_animation(self, 'SNEAK')
    else
        self._is_sneaking = false
        ia_dunce.set_animation(self, 'STAND')
    end
end
