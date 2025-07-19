-- =============================================================================
-- MAIN GAME FILE - ECS ARCHITECTURE
-- =============================================================================

-- Load ECS modules
local World = require('ecs.world')
local Systems = require('ecs.system')
local EntityFactory = require('ecs.factory')

-- Game state
local gameWorld = nil
local backgroundImage = nil
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
    gameWorld:addSystem(Systems.TargetGenerationSystem)
    gameWorld:addSystem(Systems.CombinedMovementSystem)
    gameWorld:addSystem(Systems.PulseSystem)
    gameWorld:addSystem(Systems.RenderSystem)
    print("All systems added to world")
    
    -- Get window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Create the pulsing dot
    local dotEntity = EntityFactory.createPulsingDot(gameWorld, windowWidth / 2, windowHeight / 2)
    print("Created pulsing dot entity with ID:", dotEntity.id)
    
    -- Initialize game time
    gameTime = 0
    
    print("=== LOVE.LOAD END ===")
end

function love.update(dt)
    gameTime = gameTime + dt
    
    -- Update ECS world
    gameWorld:update(dt)
    
    -- Debug: Print entity count every 2 seconds
    if math.floor(gameTime) % 2 == 0 and gameTime > 0 then
        print("Game time:", gameTime, "Entities:", #gameWorld.entities)
        for _, entity in ipairs(gameWorld.entities) do
            local transform = entity:getComponent("Transform")
            local render = entity:getComponent("Render")
            if transform and render then
                print("Entity", entity.id, "at", transform.x, transform.y, "size:", render.size)
            end
        end
    end
end

function love.draw()
    -- Draw background image
    if backgroundImage then
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        local imageWidth = backgroundImage:getWidth()
        local imageHeight = backgroundImage:getHeight()
        
        -- Calculate scale to fit image within window while maintaining aspect ratio
        local scaleX = windowWidth / imageWidth
        local scaleY = windowHeight / imageHeight
        local scale = math.min(scaleX, scaleY)
        
        -- Calculate centered position
        local scaledWidth = imageWidth * scale
        local scaledHeight = imageHeight * scale
        local imageX = (windowWidth - scaledWidth) / 2
        local imageY = (windowHeight - scaledHeight) / 2
        
        love.graphics.draw(backgroundImage, imageX, imageY, 0, scale, scale)
    end
    
    -- Render all ECS entities
    gameWorld:render()
end
