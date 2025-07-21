-- =============================================================================
-- DART BOARD BEHAVIOR MODULE
-- =============================================================================
local Components = require("ecs.component")

local DartBoardBehavior = {}

-- Add immediate shake to dart board entity
function DartBoardBehavior.shake(world, dartBoardEntity, duration, intensity)
    if not dartBoardEntity then
        print("Warning: No dart board entity provided for shaking")
        return false
    end

    duration = duration or 0.15
    intensity = intensity or 8

    local shakeComponent = Components.Shake.new(duration, intensity)
    shakeComponent.time = shakeComponent.duration -- Ready to start shaking
    world:addComponentToEntity(dartBoardEntity, "Shake", shakeComponent)

    print("Added shake to dart board with duration:", duration, "intensity:", intensity)
    return true
end

-- Check if dart board is currently shaking
function DartBoardBehavior.isShaking(dartBoardEntity)
    if not dartBoardEntity then
        return false
    end

    local shake = dartBoardEntity:getComponent("Shake")
    return shake ~= nil and shake.time > 0
end

-- Find the dart board entity in the world
function DartBoardBehavior.findDartBoard(world)
    for _, entity in ipairs(world.entities) do
        if entity:hasComponent("Image") then
            return entity -- Assuming only dart board has Image component
        end
    end
    return nil
end

-- Calculate the dart board boundaries for spawning dots
function DartBoardBehavior.getBounds(dartBoardEntity)
    if not dartBoardEntity then
        -- Fallback to window bounds if no dart board
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return {
            minX = 100,
            maxX = windowWidth - 100,
            minY = 100,
            maxY = windowHeight - 100,
        }
    end

    local transform = dartBoardEntity:getComponent("Transform")
    local image = dartBoardEntity:getComponent("Image")

    if not transform or not image then
        -- Fallback if components missing
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return {
            minX = 100,
            maxX = windowWidth - 100,
            minY = 100,
            maxY = windowHeight - 100,
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
        maxY = transform.y + halfHeight - margin,
    }
end

-- Get the center position of the dart board
function DartBoardBehavior.getCenter(dartBoardEntity)
    if not dartBoardEntity then
        -- Fallback to window center if no dart board
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return windowWidth / 2, windowHeight / 2
    end

    local transform = dartBoardEntity:getComponent("Transform")
    if transform then
        return transform.x, transform.y
    end

    -- Fallback to window center
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    return windowWidth / 2, windowHeight / 2
end

-- Get the center position of the dart board from world
function DartBoardBehavior.getCenterFromWorld(world)
    local dartBoard = DartBoardBehavior.findDartBoard(world)
    return DartBoardBehavior.getCenter(dartBoard)
end

-- Get a random position within the dart board bounds
function DartBoardBehavior.getRandomSpawnPosition(world)
    local dartBoard = DartBoardBehavior.findDartBoard(world)
    local bounds = DartBoardBehavior.getBounds(dartBoard)

    local x = bounds.minX + math.random() * (bounds.maxX - bounds.minX)
    local y = bounds.minY + math.random() * (bounds.maxY - bounds.minY)

    return x, y
end

-- Check if a position is near the center (within threshold distance)
function DartBoardBehavior.isNearCenter(world, x, y, threshold)
    threshold = threshold or 30 -- Default threshold of 30 pixels
    local centerX, centerY = DartBoardBehavior.getCenterFromWorld(world)
    local distance = math.sqrt((x - centerX) ^ 2 + (y - centerY) ^ 2)
    return distance <= threshold
end

-- Debug function to track when entities pass through center
function DartBoardBehavior.checkCenterPass(world, entity)
    local transform = entity:getComponent("Transform")
    local movement = entity:getComponent("Movement")
    if not transform or not movement then
        return false
    end

    -- Check if we're exactly at the center (50% progress)
    local progress = movement.moveTime / movement.moveDuration
    local isAtCenterPhase = math.abs(progress - 0.5) < 0.02 -- Within 2% of halfway point

    if isAtCenterPhase and DartBoardBehavior.isNearCenter(world, transform.x, transform.y, 15) then
        print(
            "Entity",
            entity.id,
            "PASSING THROUGH CENTER at",
            math.floor(transform.x),
            math.floor(transform.y),
            "progress:",
            math.floor(progress * 100) .. "%"
        )
        return true
    end
    return false
end

-- Add permanent tilt/rotation to dart board entity from impact
function DartBoardBehavior.tiltBoard(world, dartBoardEntity, maxTiltAngle, maxTiltOffset)
    if not dartBoardEntity then
        print("Warning: No dart board entity provided for tilting")
        return false
    end

    maxTiltAngle = maxTiltAngle or 0.08 -- Maximum rotation in radians (~4.5 degrees)
    maxTiltOffset = maxTiltOffset or 3 -- Maximum position offset in pixels

    local transform = dartBoardEntity:getComponent("Transform")
    if not transform then
        print("Warning: Dart board has no transform component")
        return false
    end

    -- Generate random tilt rotation (can be positive or negative)
    local tiltRotation = (math.random() - 0.5) * 2 * maxTiltAngle

    -- Generate small random position offset to simulate impact displacement
    local offsetX = (math.random() - 0.5) * 2 * maxTiltOffset
    local offsetY = (math.random() - 0.5) * 2 * maxTiltOffset

    -- Apply the tilt (accumulate with existing rotation)
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
    print(
        string.format(
            "Tilted dart board by %.2f degrees, total rotation: %.2f degrees, offset: (%.1f, %.1f)",
            angleDegrees,
            math.deg(transform.rotation),
            offsetX,
            offsetY
        )
    )

    return true
end

-- Shake the dart board if it exists in the world
function DartBoardBehavior.shakeIfExists(world, duration, intensity)
    local dartBoard = DartBoardBehavior.findDartBoard(world)
    if dartBoard then
        return DartBoardBehavior.shake(world, dartBoard, duration, intensity)
    else
        print("Warning: No dart board found in world")
        return false
    end
end

-- Tilt the dart board if it exists in the world
function DartBoardBehavior.tiltIfExists(world, maxTiltAngle, maxTiltOffset)
    local dartBoard = DartBoardBehavior.findDartBoard(world)
    if dartBoard then
        return DartBoardBehavior.tiltBoard(world, dartBoard, maxTiltAngle, maxTiltOffset)
    else
        print("Warning: No dart board found in world")
        return false
    end
end

return DartBoardBehavior
