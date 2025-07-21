-- =============================================================================
-- CIRCULAR MOVEMENT COMPONENT
-- =============================================================================

-- Circular movement component
local CircularMovementComponent = {}
CircularMovementComponent.__index = CircularMovementComponent

function CircularMovementComponent.new(radius, centerX, centerY, angle)
    local self = setmetatable({}, CircularMovementComponent)
    self.type = "CircularMovement"
    self.radius = radius or 100
    self.centerX = centerX or 0
    self.centerY = centerY or 0
    self.angle = angle or 0
    self.previousCenterX = centerX or 0
    self.previousCenterY = centerY or 0
    self.previousAngle = angle or 0
    return self
end

return CircularMovementComponent
