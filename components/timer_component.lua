-- =============================================================================
-- TIMER COMPONENT
-- =============================================================================

-- Timer Component (for delayed actions)
local Timer = {}
Timer.__index = Timer

function Timer.new(delay, componentType, component)
    local self = setmetatable({}, Timer)
    self.delay = delay or 1.0
    self.time = 0
    self.componentType = componentType -- e.g., "Shake", "Movement", etc.
    self.component = component -- The actual component instance to add
    self.triggered = false
    return self
end

return Timer
