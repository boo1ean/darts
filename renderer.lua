-- =============================================================================
-- RENDERING
-- =============================================================================
local Renderer = {}

function Renderer.drawImage(assets, gameState)
    love.graphics.draw(
        assets.image, 
        gameState.image.x, 
        gameState.image.y, 
        0, 
        gameState.image.scale, 
        gameState.image.scale
    )
end

function Renderer.drawDot(dot)
    love.graphics.setColor(1, 0, 0, 1)  -- Red color
    love.graphics.circle("fill", dot.x, dot.y, dot.size)
    love.graphics.setColor(1, 1, 1, 1)  -- Reset to white
end

return Renderer 
