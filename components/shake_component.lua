-- =============================================================================
-- SHAKE COMPONENT
-- =============================================================================

-- Shake Component
local Shake = {}
Shake.__index = Shake

function Shake.new(duration, intensity)
    local self = setmetatable({}, Shake)
    self.duration = duration or 0.3
    self.intensity = intensity or 10
    self.time = 0
    self.shakeX = 0
    self.shakeY = 0
    self.originalX = nil  -- Will store original position
    self.originalY = nil
    return self
end

return Shake 
