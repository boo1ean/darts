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

-- =============================================================================
-- SPECIFIC COMPONENTS
-- =============================================================================

-- Transform component for position, rotation, scale
local TransformComponent = {}
TransformComponent.__index = TransformComponent

function TransformComponent.new(x, y, rotation, scale)
    local self = setmetatable({}, TransformComponent)
    self.type = "Transform"
    self.x = x or 0
    self.y = y or 0
    self.rotation = rotation or 0
    self.scale = scale or 1
    return self
end

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
    self.moveDuration = 3
    self.transitionProgress = 0
    return self
end

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

return {
    Transform = TransformComponent,
    Render = RenderComponent,
    Movement = MovementComponent,
    Pulse = PulseComponent,
    CircularMovement = CircularMovementComponent,
    LinearMovement = LinearMovementComponent
} 
