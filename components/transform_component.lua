-- =============================================================================
-- TRANSFORM COMPONENT
-- =============================================================================

-- Transform component for position, rotation, scale
local TransformComponent = {}
TransformComponent.__index = TransformComponent

function TransformComponent.new(x, y, rotation, scale)
    local self = setmetatable({}, TransformComponent)
    self.type = "Transform"
    self.x = x or 0
    self.y = y or 0
    self.rotation = rotation or 0
    self.scale = scale or 1
    return self
end

return TransformComponent
