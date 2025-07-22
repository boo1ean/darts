-- =============================================================================
-- STAT DISPLAY SYSTEM - Handles generic statistic display with interpolation
-- =============================================================================
local System = require("ecs.base_system")

local StatDisplaySystem = System.new("StatDisplaySystem", { "StatDisplay", "Transform" })

function StatDisplaySystem:init(world)
    self.world = world
    self.font = love.graphics.newFont(16) -- Default font
end

function StatDisplaySystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local statDisplay = entity:getComponent("StatDisplay")
            if statDisplay then
                -- Update target value from game state
                self:updateTargetValue(statDisplay)

                -- Interpolate displayed value toward target
                self:interpolateValue(statDisplay, dt)
            end
        end
    end
end

function StatDisplaySystem:updateTargetValue(statDisplay)
    -- Get current game stats
    local gameState = self.world.gameState
    if gameState then
        if statDisplay.valueKey == "totalScore" then
            statDisplay.targetValue = gameState.totalScore or 0
        elseif statDisplay.valueKey == "hitCount" then
            statDisplay.targetValue = gameState.hitCount or 0
        elseif statDisplay.valueKey == "averageScore" then
            local total = gameState.totalScore or 0
            local hits = gameState.hitCount or 0
            statDisplay.targetValue = hits > 0 and (total / hits) or 0.0
        end
    end
end

function StatDisplaySystem:interpolateValue(statDisplay, dt)
    local speed = statDisplay.interpolationSpeed
    local diff = statDisplay.targetValue - statDisplay.displayedValue

    if math.abs(diff) > 0.01 then
        statDisplay.displayedValue = statDisplay.displayedValue + diff * speed * dt
    else
        statDisplay.displayedValue = statDisplay.targetValue
    end
end

function StatDisplaySystem:render()
    -- Store original font
    local originalFont = love.graphics.getFont()

    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local statDisplay = entity:getComponent("StatDisplay")

            if transform and statDisplay then
                -- Set font size
                local font = love.graphics.newFont(statDisplay.fontSize)
                love.graphics.setFont(font)

                -- Set color
                local color = statDisplay.color
                local r, g, b, a = color[1], color[2], color[3], color[4]
                love.graphics.setColor(r, g, b, a)

                -- Format value based on type
                local formattedValue =
                    self:formatValue(statDisplay.displayedValue, statDisplay.format, statDisplay.decimalPlaces)

                -- Create display text
                local displayText = statDisplay.label .. ": " .. formattedValue

                -- Render the text
                love.graphics.print(displayText, transform.x, transform.y)
            end
        end
    end

    -- Restore original font and color
    love.graphics.setFont(originalFont)
    love.graphics.setColor(1, 1, 1, 1)
end

function StatDisplaySystem:formatValue(value, format, decimalPlaces)
    if format == "integer" then
        return string.format("%d", math.floor(value))
    elseif format == "decimal" or format == "float" then
        local formatString = "%." .. (decimalPlaces or 1) .. "f"
        return string.format(formatString, value)
    else
        return tostring(value)
    end
end

return StatDisplaySystem
