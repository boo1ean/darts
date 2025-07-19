-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================
local Utils = {}

function Utils.getImageCenter(gameState)
    return {
        x = gameState.image.x + gameState.image.width / 2,
        y = gameState.image.y + gameState.image.height / 2
    }
end

function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.lerp(start, finish, t)
    return start + (finish - start) * t
end

function Utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function Utils.normalizeVector(x, y)
    local length = math.sqrt(x * x + y * y)
    if length > 0 then
        return x / length, y / length
    end
    return 0, 0
end

return Utils 
