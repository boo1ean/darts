-- =============================================================================
-- RENDER SYSTEM
-- =============================================================================
local System = require("ecs.base_system")

-- Render System - handles both Render and Image components
local RenderSystem = System.new("RenderSystem", { "Transform" })

function RenderSystem:canProcessEntity(entity)
    -- Process entities that have Transform and either Render or Image component
    return entity:hasComponent("Transform") and (entity:hasComponent("Render") or entity:hasComponent("Image"))
end

function RenderSystem:update(dt)
    -- Render system doesn't need update logic, just rendering
end

function RenderSystem:render()
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local render = entity:getComponent("Render")
            local image = entity:getComponent("Image")

            if render then
                -- Render shapes (circles, rectangles, etc.)
                love.graphics.setColor(render.color[1], render.color[2], render.color[3], render.color[4])

                if render.shape == "circle" then
                    love.graphics.circle("fill", transform.x, transform.y, render.size)
                elseif render.shape == "rectangle" then
                    love.graphics.rectangle(
                        "fill",
                        transform.x - render.size,
                        transform.y - render.size,
                        render.size * 2,
                        render.size * 2
                    )
                end

                love.graphics.setColor(1, 1, 1, 1) -- Reset color
            elseif image and image.image then
                -- Render images
                love.graphics.setColor(1, 1, 1, 1) -- Ensure white color for images

                -- Draw image centered at transform position with rotation around center
                -- Use offset parameters to rotate around center instead of top-left corner
                local offsetX = image.width / 2
                local offsetY = image.height / 2

                love.graphics.draw(
                    image.image,
                    transform.x,
                    transform.y,
                    transform.rotation or 0,
                    image.scaleX,
                    image.scaleY,
                    offsetX,
                    offsetY
                )
            end
        end
    end
end

return RenderSystem
