-- ia_dunce/attack.lua

--- Low-level: Is the target valid to be hit?
function ia_dunce.is_attackable(target)
    return target and target:get_hp() and target:get_hp() > 0
end

--- High-level: Am I armed and is the target attackable?
function ia_dunce.can_attack(self, target)
    if not ia_dunce.is_attackable(target) then return false end

    return ia_dunce.is_ready_to_attack(self) -- Predicate from your prev code
end

function ia_dunce.attack(self, target_obj)
    local is_weapon = function(n)
        return minetest.get_item_group(n, "sword") > 0 or minetest.get_item_group(n, "weapon") > 0
    end
    ia_dunce.wield_by_condition(self, is_weapon)
    return ia_dunce.left_click(self, target_obj, true)
end
