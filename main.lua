-- =============================================================================
-- MAIN GAME FILE - ECS ARCHITECTURE
-- =============================================================================

-- Load ECS modules
local World = require('ecs.world')
local Systems = require('ecs.system')
local EntityFactory = require('factories')

-- Load behavior modules
local GameBehavior = require('behaviors.game_behavior')
local DotBehavior = require('behaviors.dot_behavior')

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
    
    gameWorld:addSystem(Systems.ShakeSystem)
    gameWorld:addSystem(Systems.RenderSystem)
    print("All systems added to world")
    
    -- Create dart board entity
    dartBoardEntity = EntityFactory.createDartBoard(gameWorld, backgroundImage)
    print("Created dart board entity with ID:", dartBoardEntity.id)
    
    -- Create the initial pulsing dot at a random position
    GameBehavior.spawnNewDot(gameWorld)
    print("Created initial dot")
    
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
    -- Render all ECS entities (including dart board and dots)
    gameWorld:render()
end

function love.keypressed(key)
    if key == "space" then
        -- Handle dart throw using behavior module
        GameBehavior.throwDart(gameWorld, dartBoardEntity)
    end
end
