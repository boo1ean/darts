-- =============================================================================
-- MAIN GAME FILE - ECS ARCHITECTURE
-- =============================================================================

-- Save the default Love2D error handler (Love2D's fallback mechanism)
local defaultErrorHandler = love.errorhandler or love.errhand

-- Love2D's error printer function
local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", "")))
end

-- Custom error handler for AI validation vs user interaction
function love.errorhandler(msg)
    -- Check if running in AI validation mode
    local isValidationMode = os.getenv("LOVE2D_VALIDATION_MODE") == "true"

    if isValidationMode then
        -- AI validation mode: use Love2D's error printer and exit immediately
        error_printer(msg, 1)
        os.exit(1)
    else
        -- User mode: use the default Love2D error handler if available
        if defaultErrorHandler then
            return defaultErrorHandler(msg)
        else
            -- Fallback: just print error and don't exit (let Love2D handle it)
            error_printer(msg, 1)
            -- Don't call os.exit() - let Love2D show its error screen
        end
    end
end

-- Load ECS modules
local World = require("ecs.world")
local Systems = require("ecs.system")
local EntityFactory = require("factories")

-- Load behavior modules
local GameBehavior = require("behaviors.game_behavior")

-- Game state
local gameWorld = nil
local backgroundImage = nil
local dartBoardEntity = nil
local gameTime = 0

-- =============================================================================
-- LOVE2D CALLBACKS
-- =============================================================================
function love.load()
    print("=== LOVE.LOAD START ===")

    -- Initialize ECS world
    gameWorld = World.new()
    print("World created")

    -- Load background image
    backgroundImage = love.graphics.newImage("assets/board.png")
    print("Background image loaded")

    -- Add systems to world
    -- Initialize TargetGenerationSystem with world reference
    Systems.TargetGenerationSystem:init(gameWorld)
    gameWorld:addSystem(Systems.TargetGenerationSystem)

    -- Initialize CombinedMovementSystem with world reference
    Systems.CombinedMovementSystem:init(gameWorld)
    gameWorld:addSystem(Systems.CombinedMovementSystem)
    gameWorld:addSystem(Systems.PulseSystem)

    -- Initialize TimerSystem with world reference
    Systems.TimerSystem:init(gameWorld)
    gameWorld:addSystem(Systems.TimerSystem)

    -- Initialize ScoringSystem with world reference
    Systems.ScoringSystem:init(gameWorld)
    gameWorld:addSystem(Systems.ScoringSystem)

    gameWorld:addSystem(Systems.ShakeSystem)
    gameWorld:addSystem(Systems.RenderSystem)

    -- Initialize TextSystem with world reference and add it LAST for top rendering
    Systems.TextSystem:init(gameWorld)
    gameWorld:addSystem(Systems.TextSystem)

    -- Initialize StatDisplaySystem with world reference
    Systems.StatDisplaySystem:init(gameWorld)
    gameWorld:addSystem(Systems.StatDisplaySystem)
    print("All systems added to world")

    -- Create dart board entity
    dartBoardEntity = EntityFactory.createDartBoard(gameWorld, backgroundImage)
    print("Created dart board entity with ID:", dartBoardEntity.id)

    -- Create the initial pulsing dot at a random position
    GameBehavior.spawnNewDot(gameWorld)
    print("Created initial dot")

    -- Create individual stat display entities following SOLID principles
    local totalScoreEntity = EntityFactory.createTotalScoreDisplay(gameWorld, 20, 20, 16)
    local hitCountEntity = EntityFactory.createHitCountDisplay(gameWorld, 20, 41, 16) -- 16 + 5 = 21 spacing
    local averageScoreEntity = EntityFactory.createAverageScoreDisplay(gameWorld, 20, 62, 16)

    print("Created stat display entities with IDs:", totalScoreEntity.id, hitCountEntity.id, averageScoreEntity.id)

    -- Initialize game time
    gameTime = 0

    print("=== LOVE.LOAD END ===")
end

function love.update(dt)
    gameTime = gameTime + dt

    -- Update ECS world
    gameWorld:update(dt)

    -- Debug: Print game stats every 2 seconds
    if math.floor(gameTime) % 2 == 0 and gameTime > 0 then
        print("Game time:", gameTime, "Total entities:", #gameWorld.entities)
        GameBehavior.printStats(gameWorld)
    end
end

function love.draw()
    -- Render all ECS entities (including dart board, dots, and text)
    gameWorld:render()
end

function love.keypressed(key)
    if key == "space" then
        -- Handle dart throw using behavior module
        GameBehavior.throwDart(gameWorld, dartBoardEntity)
    end
end
