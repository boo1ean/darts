-- =============================================================================
-- RENDER COMPONENT
-- =============================================================================

-- Render component for visual representation
local RenderComponent = {}
RenderComponent.__index = RenderComponent

function RenderComponent.new(color, size, shape)
    local self = setmetatable({}, RenderComponent)
    self.type = "Render"
    self.color = color or {1, 1, 1, 1}
    self.size = size or 10
    self.shape = shape or "circle"
    return self
end

return RenderComponent 
