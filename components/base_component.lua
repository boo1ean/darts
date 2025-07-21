-- =============================================================================
-- COMPONENT BASE CLASS
-- =============================================================================
local Component = {}
Component.__index = Component

function Component.new(componentType)
    local self = setmetatable({}, Component)
    self.type = componentType
    return self
end

return Component
