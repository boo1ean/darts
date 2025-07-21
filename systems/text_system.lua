-- =============================================================================
-- TEXT SYSTEM - Handles animated text display
-- =============================================================================
local System = require("ecs.base_system")

-- Text System
local TextSystem = System.new("TextSystem", { "Transform", "Text" })

function TextSystem:init(world)
    self.world = world
    self.font = love.graphics.newFont(24) -- Default font
end

function TextSystem:update(dt)
    for i = #self.entities, 1, -1 do -- Iterate backwards for safe removal
        local entity = self.entities[i]
        if entity.active then
            local transform = entity:getComponent("Transform")
            local text = entity:getComponent("Text")

            if transform and text then
                text.time = text.time + dt

                -- Calculate animation progress (0 to 1)
                local progress = text.time / text.duration

                if progress >= 1.0 then
                    -- Animation finished, remove entity
                    self.world:removeEntity(entity)
                else
                    -- Update animation based on type
                    if text.animationType == "popup" then
                        self:updatePopupAnimation(text, progress)
                        -- Move text upward with easing - faster flight with velocity curve
                        local easedProgress = 1 - (1 - progress) * (1 - progress) -- Ease out quad
                        text.offsetY = -80 * easedProgress -- Move up 80 pixels with easing
                    elseif text.animationType == "fade" then
                        self:updateFadeAnimation(text, progress)
                    end
                end
            end
        end
    end
end

function TextSystem:updatePopupAnimation(text, progress)
    -- Scale animation: start small, grow to max, then settle to normal - faster fade
    if progress < 0.2 then
        -- Growing phase (0-20% of duration) - faster growth
        local scaleProgress = progress / 0.2
        text.scale = text.startScale + (text.maxScale - text.startScale) * scaleProgress
        text.alpha = scaleProgress -- Fade in
    elseif progress < 0.5 then
        -- Settling phase (20-50% of duration) - shorter settle
        local settleProgress = (progress - 0.2) / 0.3
        text.scale = text.maxScale + (text.endScale - text.maxScale) * settleProgress
        text.alpha = 1.0
    else
        -- Fade out phase (50-100% of duration) - longer fade for smoother exit
        local fadeProgress = (progress - 0.5) / 0.5
        text.scale = text.endScale
        text.alpha = 1.0 - fadeProgress
    end
end

function TextSystem:updateFadeAnimation(text, progress)
    -- Simple fade out animation
    text.scale = text.endScale
    text.alpha = 1.0 - progress
end

function TextSystem:render()
    -- Store original font
    local originalFont = love.graphics.getFont()

    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local text = entity:getComponent("Text")

            if transform and text then
                -- Set font size
                if text.fontSize then
                    local font = love.graphics.newFont(text.fontSize)
                    love.graphics.setFont(font)
                end

                -- Calculate final position with offset
                local x = transform.x
                local y = transform.y + (text.offsetY or 0)

                -- Apply color with alpha
                local r, g, b = text.color[1], text.color[2], text.color[3]
                love.graphics.setColor(r, g, b, text.alpha or 1.0)

                -- Calculate text dimensions for centering
                local textWidth = love.graphics.getFont():getWidth(text.text)
                local textHeight = love.graphics.getFont():getHeight()

                -- Apply scale and center the text
                love.graphics.push()
                love.graphics.translate(x, y)
                love.graphics.scale(text.scale or 1.0)
                love.graphics.print(text.text, -textWidth / 2, -textHeight / 2)
                love.graphics.pop()
            end
        end
    end

    -- Restore original font and color
    love.graphics.setFont(originalFont)
    love.graphics.setColor(1, 1, 1, 1)
end

return TextSystem
