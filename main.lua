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
    
    -- Initialize TimerSystem with world reference
    Systems.TimerSystem:init(gameWorld)
    gameWorld:addSystem(Systems.TimerSystem)
    
    gameWorld:addSystem(Systems.ShakeSystem)
    gameWorld:addSystem(Systems.ScreenShakeSystem)
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
    -- Get shake offset
    local shakeX, shakeY = Systems.ScreenShakeSystem:getShakeOffset()
    
    -- Apply screen shake
    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)
    
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
    
    -- Restore graphics state
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "space" then
        -- Trigger screen shake effect for dart hit
        Systems.ScreenShakeSystem:triggerShake()
        
        -- Find the currently moving dot and stop it
        for _, entity in ipairs(gameWorld.entities) do
            local movement = entity:getComponent("Movement")
            if movement and movement.movementType == "combined" then
                -- Stop pulsing at medium size
                local render = entity:getComponent("Render")
                local pulse = entity:getComponent("Pulse")
                if render and pulse then
                    -- Set to medium size (halfway between min and max)
                    local minSize = pulse.maxSize * pulse.minRatio
                    local mediumSize = minSize + (pulse.maxSize - minSize) * 0.5
                    render.size = mediumSize
                end
                
                -- Add timer for delayed shake (1 second after hit)
                local Components = require('ecs.component')
                
                -- Create the shake component that will be added later
                local shakeComponent = Components.Shake.new(0.2, 8)
                shakeComponent.time = shakeComponent.duration  -- Ready to start shaking
                
                -- Create timer that will add the shake component after 1 second
                local timerComponent = Components.Timer.new(1.0, "Shake", shakeComponent)
                gameWorld:addComponentToEntity(entity, "Timer", timerComponent)
                
                -- Remove movement-related components to stop all movement
                gameWorld:removeComponentFromEntity(entity, "Movement")
                gameWorld:removeComponentFromEntity(entity, "CircularMovement")
                gameWorld:removeComponentFromEntity(entity, "LinearMovement")
                gameWorld:removeComponentFromEntity(entity, "Pulse")
                
                print("Stopped dot with ID:", entity.id, "- will shake in 1 second")
                
                -- Spawn a new moving dot at the center
                local windowWidth = love.graphics.getWidth()
                local windowHeight = love.graphics.getHeight()
                local newDot = EntityFactory.createPulsingDot(gameWorld, windowWidth / 2, windowHeight / 2)
                print("Spawned new dot with ID:", newDot.id)
                break  -- Only stop the first moving dot found
            end
        end
    end
end
