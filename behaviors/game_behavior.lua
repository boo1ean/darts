-- =============================================================================
-- GAME BEHAVIOR MODULE - High-level game actions
-- =============================================================================
local DotBehavior = require("behaviors.dot_behavior")
local DartBoardBehavior = require("behaviors.dartboard_behavior")
local EntityFactory = require("factories")

local GameBehavior = {}

-- Handle a dart throw action (space key press)
function GameBehavior.throwDart(world, dartBoardEntity)
    print("=== DART THROW ===")

    -- 1. Shake the dart board (immediate visual feedback)
    DartBoardBehavior.shake(world, dartBoardEntity)

    -- 2. Apply permanent tilt/rotation to simulate authentic impact
    DartBoardBehavior.tiltBoard(world, dartBoardEntity)

    -- 3. Stop all moving dots
    local stoppedCount = DotBehavior.stopAllMovingDots(world)

    -- 4. Spawn a new moving dot if we stopped any dots
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
        dartBoard = DartBoardBehavior.findDartBoard(world) ~= nil,
    }
end

-- Print game statistics
function GameBehavior.printStats(world)
    local stats = GameBehavior.getStats(world)
    local scoreStats = {
        totalScore = world.gameState.totalScore,
        hitCount = world.gameState.hitCount,
        averageScore = world.gameState.hitCount > 0 and (world.gameState.totalScore / world.gameState.hitCount) or 0,
    }

    print(
        "Game Stats: Moving =",
        stats.movingDots,
        "Stopped =",
        stats.stoppedDots,
        "Total =",
        stats.totalDots,
        "Dart Board =",
        stats.dartBoard
    )
    print(
        "Score Stats: Total =",
        scoreStats.totalScore,
        "Hits =",
        scoreStats.hitCount,
        "Average =",
        math.floor(scoreStats.averageScore * 10) / 10
    )
end

return GameBehavior
