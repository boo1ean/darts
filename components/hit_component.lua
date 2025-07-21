-- =============================================================================
-- HIT COMPONENT - Marks entities for scoring processing
-- =============================================================================

local HitComponent = {}
HitComponent.__index = HitComponent

function HitComponent.new(hitTime)
    local self = setmetatable({}, HitComponent)
    self.type = "Hit"
    self.hitTime = hitTime or love.timer.getTime()
    self.processed = false -- Flag to ensure we only score once

    return self
end

return HitComponent
