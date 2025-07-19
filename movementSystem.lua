-- =============================================================================
-- MOVEMENT SYSTEM
-- =============================================================================
local Config = require('config')
local Utils = require('utils')
local TargetGenerator = require('targetGenerator')

local MovementSystem = {}

function MovementSystem.update(dot, gameState, dt)
    dot.moveTime = dot.moveTime + dt
    
    -- Check if current movement phase is complete
    if dot.moveTime >= dot.moveDuration then
        MovementSystem.startNewTransition(dot, gameState)
        dot.moveTime = 0
    end
    
    -- Update transition progress
    MovementSystem.updateTransition(dot, dt)
    
    -- Update movement components
    MovementSystem.updateCircularComponent(dot, dt)
    MovementSystem.updateLinearComponent(dot, dt)
    
    -- Combine movements
    MovementSystem.combineMovements(dot)
end

function MovementSystem.startNewTransition(dot, gameState)
    -- Store current state for smooth transition
    dot.previous.centerX = dot.circle.centerX
    dot.previous.centerY = dot.circle.centerY
    dot.previous.targetX = dot.line.targetX
    dot.previous.targetY = dot.line.targetY
    dot.previous.angle = dot.circle.angle
    
    -- Generate new targets
    TargetGenerator.generateNewTargets(dot, gameState)
    
    -- Reset transition
    dot.transitionProgress = 0
end

function MovementSystem.updateTransition(dot, dt)
    if dot.transitionProgress < 1 then
        dot.transitionProgress = dot.transitionProgress + dt / Config.TRANSITION_DURATION
        dot.transitionProgress = math.min(dot.transitionProgress, 1)
    end
end

function MovementSystem.updateCircularComponent(dot, dt)
    local progress = dot.moveTime / dot.moveDuration
    
    -- Interpolate center position
    local currentCenterX = Utils.lerp(dot.previous.centerX, dot.circle.centerX, dot.transitionProgress)
    local currentCenterY = Utils.lerp(dot.previous.centerY, dot.circle.centerY, dot.transitionProgress)
    
    -- Interpolate angle
    local currentAngle = Utils.lerp(dot.previous.angle, dot.circle.angle, dot.transitionProgress)
    local finalAngle = currentAngle + progress * math.pi * 2
    
    -- Calculate circular position
    dot.circle.x = currentCenterX + math.cos(finalAngle) * dot.circle.radius
    dot.circle.y = currentCenterY + math.sin(finalAngle) * dot.circle.radius
end

function MovementSystem.updateLinearComponent(dot, dt)
    -- Interpolate target position
    local currentTargetX = Utils.lerp(dot.previous.targetX, dot.line.targetX, dot.transitionProgress)
    local currentTargetY = Utils.lerp(dot.previous.targetY, dot.line.targetY, dot.transitionProgress)
    
    -- Move toward interpolated target
    dot.line.x = dot.line.x + (currentTargetX - dot.line.x) * (dt * Config.DOT_SPEED / 100)
    dot.line.y = dot.line.y + (currentTargetY - dot.line.y) * (dt * Config.DOT_SPEED / 100)
end

function MovementSystem.combineMovements(dot)
    -- Combine circular and linear movements using weighted average
    dot.x = dot.circle.x * Config.CIRCLE_WEIGHT + dot.line.x * Config.LINE_WEIGHT
    dot.y = dot.circle.y * Config.CIRCLE_WEIGHT + dot.line.y * Config.LINE_WEIGHT
end

return MovementSystem 
