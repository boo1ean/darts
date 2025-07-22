-- =============================================================================
-- STAT DISPLAY FACTORY - Creates individual statistic display entities
-- =============================================================================
local StatDisplayComponent = require("components.stat_display_component")
local TransformComponent = require("components.transform_component")

local StatDisplayFactory = {}

function StatDisplayFactory.createStatDisplay(world, label, valueKey, x, y, fontSize, format)
    local entity = world:createEntity()

    -- Add transform component for position
    local transform = TransformComponent.new(x, y)
    world:addComponentToEntity(entity, "Transform", transform)

    -- Add stat display component
    local statDisplay = StatDisplayComponent.new(label, valueKey, x, y, fontSize, format)
    world:addComponentToEntity(entity, "StatDisplay", statDisplay)

    return entity
end

-- Convenience functions for common stats
function StatDisplayFactory.createTotalScoreDisplay(world, x, y, fontSize)
    return StatDisplayFactory.createStatDisplay(world, "Total Score", "totalScore", x, y, fontSize, "integer")
end

function StatDisplayFactory.createHitCountDisplay(world, x, y, fontSize)
    return StatDisplayFactory.createStatDisplay(world, "Hit Count", "hitCount", x, y, fontSize, "integer")
end

function StatDisplayFactory.createAverageScoreDisplay(world, x, y, fontSize)
    return StatDisplayFactory.createStatDisplay(world, "Average Score", "averageScore", x, y, fontSize, "decimal")
end

return StatDisplayFactory