local Vector2 = {}
Vector2.__index = Vector2
function Vector2:new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, self)
end
-- Metamethods let vectors use Lua's +, == and tostring naturally.
function Vector2:__add(other) return Vector2:new(self.x + other.x, self.y + other.y) end
function Vector2:__eq(other) return self.x == other.x and self.y == other.y end
function Vector2:__tostring() return string.format("(%s, %s)", self.x, self.y) end
return Vector2
