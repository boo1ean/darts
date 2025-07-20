-- =============================================================================
-- MOVEMENT COMPONENT
-- =============================================================================

-- Movement component for movement behavior
local MovementComponent = {}
MovementComponent.__index = MovementComponent

function MovementComponent.new(speed, movementType)
    local self = setmetatable({}, MovementComponent)
    self.type = "Movement"
    self.speed = speed or 100
    self.movementType = movementType or "linear"
    self.targetX = 0
    self.targetY = 0
    self.moveTime = 0
    self.moveDuration = 1.5  -- Much faster cycles (was 3)
    self.transitionProgress = 0
    self.stopped = false  -- Flag to disable movement without removing component
    self.startX = nil  -- Starting position for center-passing movement
    self.startY = nil  -- Starting position for center-passing movement
    return self
end

return MovementComponent 
