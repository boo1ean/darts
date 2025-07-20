-- =============================================================================
-- GAME BEHAVIOR MODULE - High-level game actions
-- =============================================================================
local DotBehavior = require('behaviors.dot_behavior')
local DartBoardBehavior = require('behaviors.dartboard_behavior')
local EntityFactory = require('ecs.factory')

local GameBehavior = {}

-- Handle a dart throw action (space key press)
function GameBehavior.throwDart(world, dartBoardEntity)
    print("=== DART THROW ===")
    
    -- 1. Shake the dart board
    DartBoardBehavior.shake(world, dartBoardEntity)
    
    -- 2. Stop all moving dots
    local stoppedCount = DotBehavior.stopAllMovingDots(world)
    
    -- 3. Spawn a new moving dot if we stopped any dots
    if stoppedCount > 0 then
        GameBehavior.spawnNewDot(world)
    else
        print("No moving dots to stop - no new dot spawned")
    end
    
    return stoppedCount
end

-- Spawn a new moving dot at a random position within the dart board
function GameBehavior.spawnNewDot(world)
    local x, y = DartBoardBehavior.getRandomSpawnPosition(world)
    local newDot = EntityFactory.createPulsingDot(world, x, y)
    print("Spawned new dot with ID:", newDot.id, "at position:", math.floor(x), math.floor(y))
    return newDot
end

-- Get game statistics
function GameBehavior.getStats(world)
    local movingDots = DotBehavior.getMovingDotCount(world)
    local stoppedDots = DotBehavior.getStoppedDotCount(world)
    local totalDots = movingDots + stoppedDots
    
    return {
        movingDots = movingDots,
        stoppedDots = stoppedDots,
        totalDots = totalDots,
        dartBoard = DartBoardBehavior.findDartBoard(world) ~= nil
    }
end

-- Print game statistics
function GameBehavior.printStats(world)
    local stats = GameBehavior.getStats(world)
    print("Game Stats: Moving =", stats.movingDots, "Stopped =", stats.stoppedDots, "Total =", stats.totalDots, "Dart Board =", stats.dartBoard)
end

return GameBehavior 
