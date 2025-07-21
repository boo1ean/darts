-- =============================================================================
-- TEXT FACTORY - Creates text entities for UI and score display
-- =============================================================================
local Components = require("ecs.component")

local TextFactory = {}

-- Create a score text entity
function TextFactory.createScoreText(world, x, y, scoreText, points, color, fontSize, duration)
    local entity = world:createEntity()

    fontSize = fontSize or math.max(20, math.min(36, 20 + (points or 0) / 5))
    duration = duration or 1.3 -- Faster default duration (was 2.0)

    -- Default color based on score if not provided
    if not color then
        if points >= 100 then
            color = { 1, 1, 0, 1 } -- Gold for bullseye
        elseif points >= 50 then
            color = { 0, 1, 0, 1 } -- Green for good shots
        elseif points >= 25 then
            color = { 1, 0.8, 0, 1 } -- Orange for decent shots
        elseif points > 0 then
            color = { 1, 1, 1, 1 } -- White for any points
        else
            color = { 0.7, 0.7, 0.7, 1 } -- Gray for no points
        end
    end

    local transform = Components.Transform.new(x, y)
    local text = Components.Text.new(scoreText, fontSize, color, duration, "popup")

    world:addComponentToEntity(entity, "Transform", transform)
    world:addComponentToEntity(entity, "Text", text)

    return entity
end

-- Create a simple text entity
function TextFactory.createText(world, x, y, text, fontSize, color, duration, animationType)
    local entity = world:createEntity()

    local transform = Components.Transform.new(x, y)
    local textComponent = Components.Text.new(text, fontSize, color, duration, animationType)

    world:addComponentToEntity(entity, "Transform", transform)
    world:addComponentToEntity(entity, "Text", textComponent)

    return entity
end

return TextFactory
