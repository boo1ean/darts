-- =============================================================================
-- DARTBOARD FACTORY - Creates dartboard entities
-- =============================================================================
local Components = require("ecs.component")

local DartboardFactory = {}

-- Create a dart board entity
function DartboardFactory.createDartBoard(world, image)
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

return DartboardFactory
