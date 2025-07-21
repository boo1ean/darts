-- =============================================================================
-- GAME SYSTEM - High-level game coordination and state management
-- =============================================================================
local System = require('ecs.base_system')
local Components = require('ecs.component')
local EntityFactory = require('factories')

local GameSystem = System.new("GameSystem", {})

function GameSystem:init(world)
    self.world = world
    self.inputEvents = {}
end

function GameSystem:update(dt)
    -- Process input events
    self:processInputEvents()
end

-- Queue an input event for processing
function GameSystem:queueEvent(eventType, data)
    table.insert(self.inputEvents, {type = eventType, data = data or {}})
end

-- Process queued input events
function GameSystem:processInputEvents()
    for _, event in ipairs(self.inputEvents) do
        if event.type == "dart_throw" then
            self:handleDartThrow()
        end
    end
    -- Clear processed events
    self.inputEvents = {}
end

-- Handle dart throw action
function GameSystem:handleDartThrow()
    print("=== DART THROW ===")
    
    -- 1. Find and shake the dart board
    local dartBoard = self:findDartBoard()
    if dartBoard then
        self:shakeDartBoard(dartBoard)
        self:tiltDartBoard(dartBoard)
    end
    
    -- 2. Stop all moving dots
    local stoppedCount = self:stopAllMovingDots()
    
    -- 3. Spawn a new moving dot if we stopped any dots
    if stoppedCount > 0 then
        self:spawnNewDot()
    else
        print("No moving dots to stop - no new dot spawned")
    end
    
    return stoppedCount
end

-- Find the dart board entity
function GameSystem:findDartBoard()
    for _, entity in ipairs(self.world.entities) do
        if entity:hasComponent("Image") then
            return entity  -- Assuming only dart board has Image component
        end
    end
    return nil
end

-- Add shake to dart board
function GameSystem:shakeDartBoard(dartBoard, duration, intensity)
    duration = duration or 0.15
    intensity = intensity or 8
    
    local shakeComponent = Components.Shake.new(duration, intensity)
    shakeComponent.time = shakeComponent.duration  -- Ready to start shaking
    self.world:addComponentToEntity(dartBoard, "Shake", shakeComponent)
    
    print("Added shake to dart board with duration:", duration, "intensity:", intensity)
end

-- Add tilt to dart board
function GameSystem:tiltDartBoard(dartBoard, maxTiltAngle, maxTiltOffset)
    maxTiltAngle = maxTiltAngle or 0.08  -- Maximum rotation in radians (~4.5 degrees)
    maxTiltOffset = maxTiltOffset or 3   -- Maximum position offset in pixels
    
    local transform = dartBoard:getComponent("Transform")
    if not transform then
        print("Warning: Dart board has no transform component")
        return false
    end
    
    -- Generate random tilt rotation and position offset
    local tiltRotation = (math.random() - 0.5) * 2 * maxTiltAngle
    local offsetX = (math.random() - 0.5) * 2 * maxTiltOffset
    local offsetY = (math.random() - 0.5) * 2 * maxTiltOffset
    
    -- Apply the tilt
    transform.rotation = (transform.rotation or 0) + tiltRotation
    transform.x = transform.x + offsetX
    transform.y = transform.y + offsetY
    
    -- Clamp rotation to prevent excessive tilting (±15 degrees max)
    local maxTotalRotation = math.rad(15)
    if transform.rotation > maxTotalRotation then
        transform.rotation = maxTotalRotation
    elseif transform.rotation < -maxTotalRotation then
        transform.rotation = -maxTotalRotation
    end
    
    local angleDegrees = math.deg(tiltRotation)
    print(string.format("Tilted dart board by %.2f degrees, total rotation: %.2f degrees, offset: (%.1f, %.1f)", 
          angleDegrees, math.deg(transform.rotation), offsetX, offsetY))
end

-- Stop all moving dots and mark for scoring
function GameSystem:stopAllMovingDots()
    local stoppedCount = 0
    
    for _, entity in ipairs(self.world.entities) do
        local movement = entity:getComponent("Movement")
        if movement and movement.movementType == "combined" and not movement.stopped then
            if self:stopDotMovement(entity) then
                stoppedCount = stoppedCount + 1
                -- Add delayed shake to each stopped dot
                self:addDelayedShake(entity)
                
                -- Mark this entity for scoring by adding Hit component
                local hitComponent = Components.Hit.new()
                self.world:addComponentToEntity(entity, "Hit", hitComponent)
            end
        end
    end
    
    print("Stopped", stoppedCount, "moving dots")
    return stoppedCount
end

-- Stop movement for a single dot
function GameSystem:stopDotMovement(entity)
    local movement = entity:getComponent("Movement")
    local render = entity:getComponent("Render")
    local pulse = entity:getComponent("Pulse")
    
    if not movement or movement.stopped then
        return false  -- Already stopped or no movement component
    end
    
    -- Stop movement
    movement.stopped = true
    print("Stopped movement for entity", entity.id)
    
    -- Set to medium size if pulsing
    if render and pulse then
        local minSize = pulse.maxSize * pulse.minRatio
        local mediumSize = minSize + (pulse.maxSize - minSize) * 0.5
        render.size = mediumSize
        print("Set stopped dot size to:", mediumSize, "for entity", entity.id)
    end
    
    -- Make dot darker and 50% transparent when hit
    if render then
        render.color[1] = render.color[1] * 0.4  -- Red channel
        render.color[2] = render.color[2] * 0.4  -- Green channel  
        render.color[3] = render.color[3] * 0.4  -- Blue channel
        render.color[4] = 0.5  -- Set alpha to 50% transparency
        print("Made dot", entity.id, "darker and 50% transparent")
    end
    
    return true
end

-- Add delayed shake to a dot entity
function GameSystem:addDelayedShake(entity, delay, duration, intensity)
    delay = delay or 1.0
    duration = duration or 0.2
    intensity = intensity or 8
    
    -- Create the shake component that will be added later
    local shakeComponent = Components.Shake.new(duration, intensity)
    shakeComponent.time = shakeComponent.duration  -- Ready to start shaking
    
    -- Create timer that will add the shake component after delay
    local timerComponent = Components.Timer.new(delay, "Shake", shakeComponent)
    self.world:addComponentToEntity(entity, "Timer", timerComponent)
    
    print("Added delayed shake timer to entity", entity.id, "- will shake in", delay, "seconds")
end

-- Spawn a new moving dot at random position
function GameSystem:spawnNewDot()
    local x, y = self:getRandomSpawnPosition()
    local newDot = EntityFactory.createPulsingDot(self.world, x, y)
    print("Spawned new dot with ID:", newDot.id, "at position:", math.floor(x), math.floor(y))
    return newDot
end

-- Get random spawn position within dart board bounds
function GameSystem:getRandomSpawnPosition()
    local dartBoard = self:findDartBoard()
    local bounds = self:getDartBoardBounds(dartBoard)
    
    local x = bounds.minX + math.random() * (bounds.maxX - bounds.minX)
    local y = bounds.minY + math.random() * (bounds.maxY - bounds.minY)
    
    return x, y
end

-- Get dart board boundaries
function GameSystem:getDartBoardBounds(dartBoard)
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

-- Get game statistics
function GameSystem:getStats()
    local movingDots = 0
    local stoppedDots = 0
    
    for _, entity in ipairs(self.world.entities) do
        local movement = entity:getComponent("Movement")
        if movement and movement.movementType == "combined" then
            if movement.stopped then
                stoppedDots = stoppedDots + 1
            else
                movingDots = movingDots + 1
            end
        end
    end
    
    return {
        movingDots = movingDots,
        stoppedDots = stoppedDots,
        totalDots = movingDots + stoppedDots,
        dartBoard = self:findDartBoard() ~= nil
    }
end

-- Print game statistics
function GameSystem:printStats()
    local stats = self:getStats()
    local scoreStats = {
        totalScore = self.world.gameState.totalScore,
        hitCount = self.world.gameState.hitCount,
        averageScore = self.world.gameState.hitCount > 0 and (self.world.gameState.totalScore / self.world.gameState.hitCount) or 0
    }
    
    print("Game Stats: Moving =", stats.movingDots, "Stopped =", stats.stoppedDots, "Total =", stats.totalDots, "Dart Board =", stats.dartBoard)
    print("Score Stats: Total =", scoreStats.totalScore, "Hits =", scoreStats.hitCount, "Average =", math.floor(scoreStats.averageScore * 10) / 10)
end

return GameSystem 
