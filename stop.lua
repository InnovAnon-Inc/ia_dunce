
function ia_dunce.stop(self)
	minetest.log('ia_dunce.stop()')
    local v = self.object:get_velocity()
    if not v then return end
    self.object:set_velocity({x = 0, y = v.y, z = 0})
    ia_dunce.set_animation(self, 'STAND')
end

