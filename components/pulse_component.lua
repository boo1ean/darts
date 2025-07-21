-- =============================================================================
-- PULSE COMPONENT
-- =============================================================================

-- Pulse component for size animation
local PulseComponent = {}
PulseComponent.__index = PulseComponent

function PulseComponent.new(speed, minRatio, maxSize)
    local self = setmetatable({}, PulseComponent)
    self.type = "Pulse"
    self.speed = speed or 1
    self.minRatio = minRatio or 0.1
    self.maxSize = maxSize or 10
    self.time = 0
    return self
end

return PulseComponent
