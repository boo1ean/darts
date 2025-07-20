-- =============================================================================
-- DOT BEHAVIOR MODULE
-- =============================================================================
local Components = require('ecs.component')

local DotBehavior = {}

-- Stop a moving dot and set it to medium size
function DotBehavior.stopMovement(entity)
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
    
    return true  -- Successfully stopped
end

-- Add delayed shake to a dot entity
function DotBehavior.addDelayedShake(world, entity, delay, duration, intensity)
    delay = delay or 1.0
    duration = duration or 0.2
    intensity = intensity or 8
    
    -- Create the shake component that will be added later
    local shakeComponent = Components.Shake.new(duration, intensity)
    shakeComponent.time = shakeComponent.duration  -- Ready to start shaking
    
    -- Create timer that will add the shake component after delay
    local timerComponent = Components.Timer.new(delay, "Shake", shakeComponent)
    world:addComponentToEntity(entity, "Timer", timerComponent)
    
    print("Added delayed shake timer to entity", entity.id, "- will shake in", delay, "seconds")
end

-- Stop all moving dots in the world that match criteria and create score displays
function DotBehavior.stopAllMovingDots(world)
    local stoppedCount = 0
    local Systems = require('ecs.system')
    
    for _, entity in ipairs(world.entities) do
        local movement = entity:getComponent("Movement")
        if movement and movement.movementType == "combined" and not movement.stopped then
            if DotBehavior.stopMovement(entity) then
                stoppedCount = stoppedCount + 1
                -- Add delayed shake to each stopped dot
                DotBehavior.addDelayedShake(world, entity)
                
                -- Create score display for this hit
                local transform = entity:getComponent("Transform")
                if transform then
                    Systems.ScoringSystem:scoreHit(transform.x, transform.y)
                end
            end
        end
    end
    
    print("Stopped", stoppedCount, "moving dots")
    return stoppedCount
end

-- Check if a dot is currently moving
function DotBehavior.isMoving(entity)
    local movement = entity:getComponent("Movement")
    return movement and movement.movementType == "combined" and not movement.stopped
end

-- Check if a dot is stopped
function DotBehavior.isStopped(entity)
    local movement = entity:getComponent("Movement")
    return movement and movement.movementType == "combined" and movement.stopped
end

-- Get count of moving dots in world
function DotBehavior.getMovingDotCount(world)
    local count = 0
    for _, entity in ipairs(world.entities) do
        if DotBehavior.isMoving(entity) then
            count = count + 1
        end
    end
    return count
end

-- Get count of stopped dots in world
function DotBehavior.getStoppedDotCount(world)
    local count = 0
    for _, entity in ipairs(world.entities) do
        if DotBehavior.isStopped(entity) then
            count = count + 1
        end
    end
    return count
end

return DotBehavior 
