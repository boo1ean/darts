-- =============================================================================
-- TARGET GENERATION SYSTEM
-- =============================================================================
local System = require('ecs.base_system')

-- Target Generation System
local TargetGenerationSystem = System.new("TargetGenerationSystem", {"Movement", "CircularMovement", "LinearMovement", "CosineMovement"})

function TargetGenerationSystem:init(world)
    self.world = world  -- Store reference to world for accessing dart board
end

function TargetGenerationSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local movement = entity:getComponent("Movement")
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            local cosine = entity:getComponent("CosineMovement")
            
            -- Safety check: only process if all components exist and movement is not stopped
            if movement and circular and linear and cosine and not movement.stopped then
                movement.moveTime = movement.moveTime + dt
                
                if movement.moveTime >= movement.moveDuration then
                    self:generateNewTargets(entity)
                    movement.moveTime = 0
                end
            end
        end
    end
end

function TargetGenerationSystem:generateNewTargets(entity)
    local circular = entity:getComponent("CircularMovement")
    local linear = entity:getComponent("LinearMovement")
    local cosine = entity:getComponent("CosineMovement")
    local movement = entity:getComponent("Movement")
    
    -- Store previous values
    circular.previousCenterX = circular.centerX
    circular.previousCenterY = circular.centerY
    circular.previousAngle = circular.angle
    linear.previousTargetX = linear.targetX
    linear.previousTargetY = linear.targetY
    
    -- Randomize cosine movement parameters for variety (ECS compliant - logic in system)
    self:randomizeCosineParameters(cosine)
    
    -- Get dart board center and bounds for movement targets
    local dartBoard = self:findDartBoard()
    local bounds = self:getDartBoardBounds(dartBoard)
    local centerX, centerY = self:getDartBoardCenter(dartBoard)
    
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minY = bounds.minY
    local maxY = bounds.maxY
    
    -- Generate random targets within board bounds
    -- Center passage is now guaranteed by the movement system itself
    circular.centerX = minX + math.random() * (maxX - minX)
    circular.centerY = minY + math.random() * (maxY - minY)
    circular.angle = math.random() * math.pi * 2
    
    linear.targetX = minX + math.random() * (maxX - minX)
    linear.targetY = minY + math.random() * (maxY - minY)
    
    print("Entity", entity.id, "- AGGRESSIVE FAST targets! Duration:", string.format("%.1f", movement.moveDuration), "s - EXTREME X-Path Factor:", string.format("%.1f", cosine.factor))
    
    movement.moveDuration = 1 + math.random() * 1  -- Random 1-2 seconds (was 2.5-3.5)
    movement.transitionProgress = 0
    
    -- Reset start position for new movement cycle
    movement.startX = nil
    movement.startY = nil
    
    -- Reset cosine time for new wave cycle
    cosine.time = 0
end

-- Find the dart board entity
function TargetGenerationSystem:findDartBoard()
    for _, entity in ipairs(self.world.entities) do
        if entity:hasComponent("Image") then
            return entity  -- Assuming only dart board has Image component
        end
    end
    return nil
end

-- Get dart board boundaries
function TargetGenerationSystem:getDartBoardBounds(dartBoard)
    if not dartBoard then
        -- Fallback to window bounds if no dart board
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return {
            minX = 100,
            maxX = windowWidth - 100,
            minY = 100,
            maxY = windowHeight - 100
        }
    end
    
    local transform = dartBoard:getComponent("Transform")
    local image = dartBoard:getComponent("Image")
    
    if not transform or not image then
        -- Fallback if components missing
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return {
            minX = 100,
            maxX = windowWidth - 100,
            minY = 100,
            maxY = windowHeight - 100
        }
    end
    
    -- Calculate dart board bounds
    local scaledWidth = image.width * image.scaleX
    local scaledHeight = image.height * image.scaleY
    local halfWidth = scaledWidth / 2
    local halfHeight = scaledHeight / 2
    
    -- Add some margin to keep dots within the board area
    local margin = 50
    
    return {
        minX = transform.x - halfWidth + margin,
        maxX = transform.x + halfWidth - margin,
        minY = transform.y - halfHeight + margin,
        maxY = transform.y + halfHeight - margin
    }
end

-- Get the center position of the dart board
function TargetGenerationSystem:getDartBoardCenter(dartBoard)
    if not dartBoard then
        -- Fallback to window center if no dart board
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return windowWidth / 2, windowHeight / 2
    end
    
    local transform = dartBoard:getComponent("Transform")
    if transform then
        return transform.x, transform.y
    end
    
    -- Fallback to window center
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    return windowWidth / 2, windowHeight / 2
end

-- Randomize cosine movement parameters (ECS compliant - system contains logic)
function TargetGenerationSystem:randomizeCosineParameters(cosine)
    -- Store current as previous
    cosine.previousFactor = cosine.factor
    cosine.previousAmplitudeX = cosine.amplitudeX
    cosine.previousAmplitudeY = cosine.amplitudeY
    cosine.previousFrequencyX = cosine.frequencyX
    cosine.previousFrequencyY = cosine.frequencyY
    cosine.previousPhaseX = cosine.phaseX
    cosine.previousPhaseY = cosine.phaseY
    
    -- Generate new random parameters - AGGRESSIVE FACTOR RANGE
    cosine.factor = 0.1 + math.random() * 2.9     -- Random 0.1-3.0 (EXTREME intensity control)
    cosine.amplitudeX = 5 + math.random() * 25    -- Random 5-30 (AGGRESSIVE oscillation range)
    cosine.amplitudeY = 5 + math.random() * 25    -- Random 5-30 (AGGRESSIVE oscillation range)
    cosine.frequencyX = 0.5 + math.random() * 2.5 -- Random 0.5-3.0 (AGGRESSIVE wave speeds)
    cosine.frequencyY = 0.5 + math.random() * 2.5 -- Random 0.5-3.0 (AGGRESSIVE wave speeds)
    cosine.phaseX = math.random() * math.pi * 2
    cosine.phaseY = math.random() * math.pi * 2
    
    print("  AGGRESSIVE wave: Factor(" .. string.format("%.1f", cosine.factor) .. ") affects PATH+WAVES Amp(" .. math.floor(cosine.amplitudeX) .. "," .. math.floor(cosine.amplitudeY) .. ") Freq(" .. string.format("%.1f", cosine.frequencyX) .. "," .. string.format("%.1f", cosine.frequencyY) .. ") - EXTREME & FAST!")
end

return TargetGenerationSystem 
