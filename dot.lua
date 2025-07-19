-- =============================================================================
-- DOT STATE
-- =============================================================================
local Config = require('config')

local Dot = {
    -- Current position
    x = 0,
    y = 0,
    size = 0,
    
    -- Movement components
    circle = {
        x = 0,
        y = 0,
        centerX = 0,
        centerY = 0,
        angle = 0,
        radius = Config.CIRCLE_RADIUS
    },
    line = {
        x = 0,
        y = 0,
        targetX = 0,
        targetY = 0
    },
    
    -- Animation state
    moveTime = 0,
    moveDuration = 0,
    transitionProgress = 0,
    
    -- Previous state for smooth transitions
    previous = {
        centerX = 0,
        centerY = 0,
        targetX = 0,
        targetY = 0,
        angle = 0
    }
}

return Dot 
