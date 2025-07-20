-- =============================================================================
-- SCORE COMPONENT - For storing score information
-- =============================================================================

local ScoreComponent = {}
ScoreComponent.__index = ScoreComponent

function ScoreComponent.new(points, distanceFromCenter, hitPosition)
    local self = setmetatable({}, ScoreComponent)
    self.type = "Score"
    self.points = points or 0
    self.distanceFromCenter = distanceFromCenter or 0
    self.hitPosition = hitPosition or {x = 0, y = 0}
    self.timestamp = love.timer.getTime()
    
    return self
end

return ScoreComponent 
