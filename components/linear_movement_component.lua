-- =============================================================================
-- LINEAR MOVEMENT COMPONENT
-- =============================================================================

-- Linear movement component
local LinearMovementComponent = {}
LinearMovementComponent.__index = LinearMovementComponent

function LinearMovementComponent.new(targetX, targetY)
    local self = setmetatable({}, LinearMovementComponent)
    self.type = "LinearMovement"
    self.targetX = targetX or 0
    self.targetY = targetY or 0
    self.previousTargetX = targetX or 0
    self.previousTargetY = targetY or 0
    return self
end

return LinearMovementComponent 
