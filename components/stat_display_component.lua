-- =============================================================================
-- STAT DISPLAY COMPONENT - Generic component for displaying any statistic
-- =============================================================================
local BaseComponent = require("components.base_component")

local StatDisplayComponent = {}
StatDisplayComponent.__index = StatDisplayComponent
setmetatable(StatDisplayComponent, BaseComponent)

function StatDisplayComponent.new(label, valueKey, x, y, fontSize, format)
    local self = setmetatable(BaseComponent.new("StatDisplay"), StatDisplayComponent)

    -- Display properties
    self.label = label or "Stat" -- Display label (e.g., "Total Score")
    self.valueKey = valueKey or "value" -- Key to read from game state
    self.x = x or 0 -- Screen position
    self.y = y or 0
    self.fontSize = fontSize or 16
    self.color = { 1, 1, 1, 1 } -- White text

    -- Value formatting
    self.format = format or "integer" -- "integer", "decimal", "float"
    self.decimalPlaces = 1 -- For decimal/float formats

    -- Current displayed value (for interpolation)
    self.displayedValue = 0

    -- Target value (actual game state)
    self.targetValue = 0

    -- Interpolation settings
    self.interpolationSpeed = 5.0 -- How fast values animate to target

    return self
end

return StatDisplayComponent
