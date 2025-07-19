-- =============================================================================
-- TARGET GENERATION
-- =============================================================================
local Config = require('config')
local Utils = require('utils')

local TargetGenerator = {}

function TargetGenerator.generateNewTargets(dot, gameState)
    local center = Utils.getImageCenter(gameState)
    
    -- Generate circular center that ensures circle passes through image center
    TargetGenerator.generateCircularTarget(dot, center)
    
    -- Generate linear target that passes through image center
    TargetGenerator.generateLinearTarget(dot, center, gameState)
    
    -- Randomize duration slightly for organic movement
    dot.moveDuration = Config.CIRCLE_DURATION + (math.random() - 0.5) * 1
end

function TargetGenerator.generateCircularTarget(dot, center)
    -- Calculate position within 80% of radius from center
    local angle = math.random() * math.pi * 2
    local distance = math.random() * (Config.CIRCLE_RADIUS * 0.8)
    
    dot.circle.centerX = center.x + math.cos(angle) * distance
    dot.circle.centerY = center.y + math.sin(angle) * distance
    dot.circle.angle = math.random() * math.pi * 2
end

function TargetGenerator.generateLinearTarget(dot, center, gameState)
    -- Calculate direction from current position to center
    local dirX = center.x - dot.x
    local dirY = center.y - dot.y
    local length = Utils.distance(dot.x, dot.y, center.x, center.y)
    
    if length > 0 then
        -- Normalize direction and place target on opposite side
        local normX, normY = Utils.normalizeVector(dirX, dirY)
        local targetDistance = math.random() * (gameState.image.width * 0.3) + 50
        
        dot.line.targetX = center.x + normX * targetDistance
        dot.line.targetY = center.y + normY * targetDistance
        
        -- Ensure target stays within image bounds
        dot.line.targetX = Utils.clamp(dot.line.targetX, gameState.image.x, gameState.image.x + gameState.image.width)
        dot.line.targetY = Utils.clamp(dot.line.targetY, gameState.image.y, gameState.image.y + gameState.image.height)
    else
        -- Fallback if current position is at center
        dot.line.targetX = gameState.image.x + math.random() * gameState.image.width
        dot.line.targetY = gameState.image.y + math.random() * gameState.image.height
    end
end

return TargetGenerator 
