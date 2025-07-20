-- =============================================================================
-- ENTITY FACTORY
-- =============================================================================
local Components = require('ecs.component')

local EntityFactory = {}

-- Create a pulsing dot with combined movement
function EntityFactory.createPulsingDot(world, x, y)
    local entity = world:createEntity()
    
    -- Add components with proper initial values
    local Components = require('ecs.component')
    
    local transform = Components.Transform.new(x, y)
    local render = Components.Render.new({1, 0, 0, 1}, 10, "circle")
    local movement = Components.Movement.new(800, "combined")  -- Much faster (was 500)
    local pulse = Components.Pulse.new(0.2, 0.1, 10)  -- Smooth, gentle pulsing (reduced from 1.5)
    local circular = Components.CircularMovement.new(80, x, y, 0)  -- Increased radius from 50 to 80
    local linear = Components.LinearMovement.new(x, y)
    -- Create cosine movement with AGGRESSIVE factor for EXTREME variety
    local randomFactor = 0.1 + math.random() * 2.9  -- Random 0.1-3.0 for EXTREME factor variety
    local cosine = Components.CosineMovement.new(nil, nil, nil, nil, nil, nil, randomFactor)
    
    -- Use the new method to add components
    world:addComponentToEntity(entity, "Transform", transform)
    world:addComponentToEntity(entity, "Render", render)
    world:addComponentToEntity(entity, "Movement", movement)
    world:addComponentToEntity(entity, "Pulse", pulse)
    world:addComponentToEntity(entity, "CircularMovement", circular)
    world:addComponentToEntity(entity, "LinearMovement", linear)
    world:addComponentToEntity(entity, "CosineMovement", cosine)
    
    -- Set initial targets for movement
    local movementComp = entity:getComponent("Movement")
    local circularComp = entity:getComponent("CircularMovement")
    local linearComp = entity:getComponent("LinearMovement")
    
    -- Set initial targets closer to center
    local offset = 50  -- Smaller offset to keep dot closer to center
    
    circularComp.centerX = x
    circularComp.centerY = y
    circularComp.previousCenterX = x
    circularComp.previousCenterY = y
    
    linearComp.targetX = x + offset
    linearComp.targetY = y + offset
    linearComp.previousTargetX = x + offset
    linearComp.previousTargetY = y + offset
    
    movementComp.targetX = x + offset
    movementComp.targetY = y + offset
    movementComp.moveTime = 0
    movementComp.moveDuration = 3
    movementComp.transitionProgress = 1  -- Start fully transitioned
    
    return entity
end

-- Create a simple moving dot
function EntityFactory.createMovingDot(world, x, y)
    local entity = world:createEntity()
    
    entity:addComponent("Transform", Components.Transform.new(x, y))
    entity:addComponent("Render", Components.Render.new({0, 1, 0, 1}, 8, "circle"))
    entity:addComponent("Movement", Components.Movement.new(200, "linear"))
    
    return entity
end

-- Create a circular moving dot
function EntityFactory.createCircularDot(world, x, y)
    local entity = world:createEntity()
    
    entity:addComponent("Transform", Components.Transform.new(x, y))
    entity:addComponent("Render", Components.Render.new({0, 0, 1, 1}, 6, "circle"))
    entity:addComponent("CircularMovement", Components.CircularMovement.new(80, x, y, 0))
    
    return entity
end

-- Create a pulsing dot without movement
function EntityFactory.createStaticPulsingDot(world, x, y)
    local entity = world:createEntity()
    
    entity:addComponent("Transform", Components.Transform.new(x, y))
    entity:addComponent("Render", Components.Render.new({1, 1, 0, 1}, 12, "circle"))
    entity:addComponent("Pulse", Components.Pulse.new(0.15, 0.2, 12))  -- Smooth, gentle pulsing for dart board
    
    return entity
end

-- Create a dart board entity
function EntityFactory.createDartBoard(world, image)
    local entity = world:createEntity()
    
    -- Get window and image dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local imageWidth = image:getWidth()
    local imageHeight = image:getHeight()
    
    -- Calculate scale to fit image within window while maintaining aspect ratio
    local scaleX = windowWidth / imageWidth
    local scaleY = windowHeight / imageHeight
    local scale = math.min(scaleX, scaleY)
    
    -- Calculate centered position
    local scaledWidth = imageWidth * scale
    local scaledHeight = imageHeight * scale
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    
    -- Create components
    local transform = Components.Transform.new(centerX, centerY)
    local imageComponent = Components.Image.new(image, imageWidth, imageHeight)
    imageComponent.scaleX = scale
    imageComponent.scaleY = scale
    
    -- Add components to entity
    world:addComponentToEntity(entity, "Transform", transform)
    world:addComponentToEntity(entity, "Image", imageComponent)
    
    return entity
end

return EntityFactory 
